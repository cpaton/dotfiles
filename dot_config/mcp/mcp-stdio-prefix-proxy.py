#!/usr/bin/env python3
"""Thin MCP stdio proxy that prefixes tool names from an upstream server.

Replaces the FastMCP-based mcp-prefix-proxy.py with a zero-dependency proxy
that correctly handles mcp-grafana v2's strict protocol enforcement (rejects
duplicate "initialize" messages).

How it works:
- Spawns the upstream MCP server as a subprocess
- Forwards JSON-RPC messages between client (stdin/stdout) and upstream
- Prefixes tool names in tools/list responses with <prefix>_
- Strips the prefix from tool names in tools/call requests
- Deduplicates "initialize" — only the first is forwarded to the upstream;
  subsequent ones get the cached response immediately

Usage: mcp-stdio-prefix-proxy <prefix> -- <command> [args...]

Example:
  mcp-stdio-prefix-proxy non_prod -- pwsh -NoProfile -File ~/.config/mcp/grafana-non-prod.ps1
"""

import json
import os
import subprocess
import sys
import threading


def read_jsonrpc(stream):
    """Read a single newline-delimited JSON-RPC message from a byte stream."""
    line = stream.readline()
    if not line:
        return None
    return json.loads(line)


def write_jsonrpc(stream, msg):
    """Write a single newline-delimited JSON-RPC message to a byte stream."""
    stream.write(json.dumps(msg, separators=(",", ":")).encode() + b"\n")
    stream.flush()


def prefix_tool_name(prefix, name):
    return f"{prefix}_{name}"


def strip_tool_prefix(prefix, name):
    p = f"{prefix}_"
    return name[len(p):] if name.startswith(p) else name


def rewrite_tools_list(prefix, result):
    """Prefix tool names in a tools/list response."""
    if "tools" in result:
        for tool in result["tools"]:
            if "name" in tool:
                tool["name"] = prefix_tool_name(prefix, tool["name"])
    return result


def main():
    args = sys.argv[1:]
    if "--" not in args:
        print(
            "Usage: mcp-stdio-prefix-proxy <prefix> -- <command> [args...]",
            file=sys.stderr,
        )
        sys.exit(1)

    sep = args.index("--")
    prefix = args[0]
    command_args = [os.path.expanduser(a) for a in args[sep + 1:]]

    # Start the upstream MCP server
    proc = subprocess.Popen(
        command_args,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=sys.stderr,
    )

    # Track pending requests so we know how to rewrite responses
    pending = {}  # id -> method
    lock = threading.Lock()

    # Initialize dedup: cache the first initialize response so we can replay
    # it for any subsequent initialize requests without hitting the upstream.
    init_response = None  # set after first successful initialize
    init_event = threading.Event()

    def upstream_to_client():
        """Read from upstream stdout, rewrite, write to client stdout."""
        nonlocal init_response
        try:
            while True:
                msg = read_jsonrpc(proc.stdout)
                if msg is None:
                    break

                msg_id = msg.get("id")
                if msg_id is not None and "result" in msg:
                    with lock:
                        method = pending.pop(msg_id, None)

                    if method == "initialize":
                        init_response = msg["result"]
                        init_event.set()
                    elif method == "tools/list":
                        msg["result"] = rewrite_tools_list(prefix, msg["result"])

                write_jsonrpc(sys.stdout.buffer, msg)
        except (BrokenPipeError, OSError):
            pass

    reader = threading.Thread(target=upstream_to_client, daemon=True)
    reader.start()

    # Main thread: read from client stdin, rewrite, write to upstream
    initialized = False
    try:
        while True:
            msg = read_jsonrpc(sys.stdin.buffer)
            if msg is None:
                break

            method = msg.get("method")
            msg_id = msg.get("id")

            # Dedup initialize: forward only the first, replay cached for rest
            if method == "initialize":
                if not initialized:
                    initialized = True
                    if msg_id is not None:
                        with lock:
                            pending[msg_id] = method
                    write_jsonrpc(proc.stdin, msg)
                else:
                    # Wait for the first initialize to complete so we have a
                    # cached response, then replay it with the new request id.
                    init_event.wait(timeout=30)
                    if init_response is not None and msg_id is not None:
                        reply = {
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "result": init_response,
                        }
                        write_jsonrpc(sys.stdout.buffer, reply)
                    continue

            else:
                if msg_id is not None and method is not None:
                    with lock:
                        pending[msg_id] = method

                # Strip prefix from tool names in tools/call requests
                if method == "tools/call":
                    params = msg.get("params", {})
                    if "name" in params:
                        params["name"] = strip_tool_prefix(prefix, params["name"])

                write_jsonrpc(proc.stdin, msg)

    except (BrokenPipeError, OSError, KeyboardInterrupt):
        pass
    finally:
        proc.stdin.close()
        proc.wait()
        sys.exit(proc.returncode or 0)


if __name__ == "__main__":
    main()
