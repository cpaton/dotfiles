---
name: home-mqtt
description: Connects to the user's Home Assistant MQTT broker and captures messages from approved topics without publishing. Use when the user wants to read MQTT messages, test Mosquitto access, or observe Home Assistant or Zigbee2MQTT state or command traffic.
---

# Home MQTT

## Connection

| Setting | Value |
| --- | --- |
| Broker | `mqtt.lt.lan:1883` |
| Transport | Plain MQTT on the trusted LAN (no TLS) |
| Account | `diagnostic` |
| Password | `MOSQUITTO_DIAGNOSTIC`, inherited by the local agent process |
| Zigbee2MQTT base topic | `zigbee2mqtt` |

Use the diagnostic account only. Never ask for the password in chat, print it, pass it on the command line, or save it with a capture. If the variable is missing, ask the user to make it available to the agent process. Do not fall back to Home Assistant or Zigbee2MQTT service credentials.

## Quick start

Use the bundled [subscriber](scripts/mqtt_subscribe.py) with Python 3.9+; no MQTT client or Python packages are required. Replace the example name with a topic the user approved:

```powershell
$subscriber = Join-Path $HOME '.config\opencode\skills\home-mqtt\scripts\mqtt_subscribe.py'
python -B $subscriber --topic 'zigbee2mqtt/example-device' --seconds 60
```

Repeat `--topic` to watch multiple topic filters. Output is timestamped JSON Lines on stdout, with subscription results, messages, and a capture summary. The capture stops after 60 seconds or 500 messages by default; adjust with `--seconds` (up to 1800) and `--max-messages` (up to 5000). Run longer captures in the background.

## Workflow

1. Confirm the topic scope from the request. If it is unclear, ask for the exact MQTT topics or the Zigbee2MQTT friendly name. Prefer exact topics over wildcard filters. Never subscribe to the entire broker.
2. For Zigbee2MQTT device state, subscribe to `zigbee2mqtt/<friendly_name>`. To observe commands, add `zigbee2mqtt/<friendly_name>/set/#` if approved; this matches `/set` and its per-property subtopics. The broker must grant read access to the relevant topics.
3. Subscribe using the helper. It never publishes, sends `/get` requests, changes settings, or changes broker ACLs. Record the capture interval in UTC; distinguish messages marked `retained: true` from live traffic.
4. Report what arrived, on which topics, and when. A successful subscription acknowledgement does not prove delivery or verify the account is read-only. An empty window may mean no retained message, no new traffic, a topic mismatch, or an ACL restriction. Check the exact topic and ACL or extend the capture; do not change the device just to provoke traffic.

See the [Zigbee2MQTT topic reference](https://www.zigbee2mqtt.io/guide/usage/mqtt_topics_and_messages.html) for topic conventions. MQTT subscriptions do not provide historical messages.
