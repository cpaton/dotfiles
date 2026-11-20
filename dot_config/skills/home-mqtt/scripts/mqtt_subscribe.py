"""Bounded MQTT 3.1.1 QoS 0 subscriber for the local diagnostic account."""

import argparse
from collections import Counter
from datetime import datetime, timezone
import json
import os
import select
import socket
import sys
import time
import uuid

HOST, PORT = "mqtt.lt.lan", 1883
USERNAME, PASSWORD_ENV = "diagnostic", "MOSQUITTO_DIAGNOSTIC"
KEEPALIVE = 30
MAX_PACKET = 1024 * 1024


class MqttError(Exception):
    pass


def log(**event):
    timestamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds")
    print(json.dumps({"received_at": timestamp, **event}), flush=True)


def field(value):
    data = value.encode("utf-8")
    if len(data) > 65535:
        raise MqttError("MQTT field is too long")
    return len(data).to_bytes(2, "big") + data


def packet(header, body=b""):
    length = len(body)
    prefix = bytearray([header])
    while length >= 128:
        prefix.append((length % 128) | 128)
        length //= 128
    prefix.append(length)
    return bytes(prefix) + body


def topic_filter(value):
    levels = value.split("/")
    if not value or "\x00" in value or len(value.encode("utf-8")) > 65535:
        raise argparse.ArgumentTypeError("invalid MQTT topic filter")
    for index, level in enumerate(levels):
        if "+" not in level and "#" not in level:
            continue
        if level not in {"+", "#"} or (level == "#" and index != len(levels) - 1):
            raise argparse.ArgumentTypeError("invalid MQTT wildcard")
        if index < 2 or not all(levels[:2]):
            raise argparse.ArgumentTypeError(
                "wildcards require at least two leading literal topic levels"
            )
    return value


class PacketReader:
    def __init__(self, sock):
        self.sock = sock
        self.buffer = bytearray()

    def _parse(self):
        length = 0
        for index in range(1, min(len(self.buffer), 5)):
            digit = self.buffer[index]
            length += (digit & 127) << (7 * (index - 1))
            if not digit & 128:
                if length > MAX_PACKET:
                    raise MqttError("incoming MQTT packet exceeds 1 MiB")
                start = index + 1
                if len(self.buffer) < start + length:
                    return None
                header = self.buffer[0]
                body = bytes(self.buffer[start:start + length])
                del self.buffer[:start + length]
                return header, body
        if len(self.buffer) >= 5:
            raise MqttError("invalid MQTT packet length")
        return None

    def read(self, deadline):
        while (remaining := deadline - time.monotonic()) > 0:
            frame = self._parse()
            if frame is not None:
                return frame
            if not select.select([self.sock], [], [], remaining)[0]:
                break
            data = self.sock.recv(65536)
            if not data:
                raise MqttError("broker closed the connection")
            self.buffer.extend(data)
        return None


def publish_fields(header, body):
    if header & 6 or len(body) < 2:
        raise MqttError("invalid PUBLISH for a QoS 0 subscription")
    length = int.from_bytes(body[:2], "big")
    if not 0 < length <= len(body) - 2:
        raise MqttError("invalid PUBLISH topic length")
    topic = body[2:2 + length].decode("utf-8")
    raw = body[2 + length:].decode("utf-8", errors="replace")
    try:
        payload = json.loads(raw)
    except (ValueError, RecursionError):
        payload = raw
    return topic, bool(header & 1), payload


def subscribe(filters, seconds, max_messages, password):
    if not password:
        raise MqttError(f"{PASSWORD_ENV} is not set in this process")
    client_id = "diag-" + uuid.uuid4().hex[:16]
    connect = (
        field("MQTT") + b"\x04\xc2" + KEEPALIVE.to_bytes(2, "big")
        + field(client_id) + field(USERNAME) + field(password)
    )
    request = b"\x00\x01" + b"".join(field(topic) + b"\x00" for topic in filters)
    if len(request) > MAX_PACKET:
        raise MqttError("subscription request exceeds 1 MiB")

    counts = Counter()
    total = 0

    def report_message(header, body):
        nonlocal total
        if total >= max_messages:
            return
        topic, retained, payload = publish_fields(header, body)
        counts[topic, "retained" if retained else "live"] += 1
        total += 1
        log(event="message", topic=topic, retained=retained, payload=payload)

    with socket.create_connection((HOST, PORT), timeout=5) as sock:
        reader = PacketReader(sock)
        sock.sendall(packet(0x10, connect))
        response = reader.read(time.monotonic() + 5)
        if response is None:
            raise MqttError("timed out waiting for CONNACK")
        header, body = response
        if header != 0x20 or len(body) != 2:
            raise MqttError("invalid CONNACK")
        if body[1]:
            raise MqttError(f"broker rejected CONNECT (code {body[1]})")

        sock.sendall(packet(0x82, request))
        ack_deadline = time.monotonic() + 5
        while True:
            response = reader.read(ack_deadline)
            if response is None:
                raise MqttError("timed out waiting for SUBACK")
            header, body = response
            if header >> 4 == 3:
                report_message(header, body)
                continue
            if header != 0x90 or body[:2] != b"\x00\x01" or len(body) != 2 + len(filters):
                raise MqttError("invalid SUBACK")
            codes = dict(zip(filters, body[2:]))
            log(event="subscriptions", return_codes=codes)
            if not any(code == 0 for code in codes.values()):
                raise MqttError("broker did not grant any requested subscriptions")
            break

        start = time.monotonic()
        end = start + seconds
        next_ping = start + KEEPALIVE / 2
        waiting_for_ping = False
        while total < max_messages and (now := time.monotonic()) < end:
            if now >= next_ping:
                if waiting_for_ping:
                    raise MqttError("broker did not respond to PINGREQ")
                sock.sendall(packet(0xC0))
                waiting_for_ping = True
                next_ping = now + KEEPALIVE / 2
            response = reader.read(min(end, next_ping))
            if response is None:
                continue
            header, body = response
            if header >> 4 == 3:
                report_message(header, body)
            elif header == 0xD0 and not body:
                waiting_for_ping = False
        sock.sendall(packet(0xE0))

    log(
        event="summary",
        reason="message_limit" if total >= max_messages else "duration",
        total=total,
        counts={
            topic: {kind: counts[topic, kind] for kind in ("retained", "live")}
            for topic in sorted({topic for topic, _ in counts})
        },
    )
    return 1 if any(code != 0 for code in codes.values()) else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--topic", action="append", required=True, type=topic_filter)
    parser.add_argument("--seconds", type=int, default=60, help="capture duration (1-1800)")
    parser.add_argument("--max-messages", type=int, default=500, help="message cap (1-5000)")
    args = parser.parse_args()
    if not 1 <= args.seconds <= 1800 or not 1 <= args.max_messages <= 5000:
        parser.error("seconds must be 1-1800 and max-messages must be 1-5000")
    try:
        return subscribe(
            list(dict.fromkeys(args.topic)), args.seconds, args.max_messages, os.getenv(PASSWORD_ENV)
        )
    except (MqttError, OSError) as error:
        print(f"MQTT capture failed: {error}", file=sys.stderr)
        return 1
    except UnicodeError:
        print("MQTT capture failed: invalid text encoding", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
