#!/usr/bin/env python3
"""MCP stdio proxy that prefixes all tool names from an upstream server.

Usage: mcp-prefix-proxy <prefix> -- <command> [args...]

Example:
  mcp-prefix-proxy non_prod -- pwsh -NoProfile -Command "& ~/.config/mcp/grafana-non-prod.ps1"

All tools from the upstream server will be exposed as <prefix>_<original_name>.
"""

import os
import sys

from fastmcp import FastMCP
from fastmcp.server import create_proxy

def main():
    args = sys.argv[1:]
    if "--" not in args:
        print("Usage: mcp-prefix-proxy <prefix> -- <command> [args...]", file=sys.stderr)
        sys.exit(1)

    sep = args.index("--")
    prefix = args[0]
    command_args = [os.path.expanduser(a) for a in args[sep + 1:]]

    config = {
        "mcpServers": {
            "default": {
                "command": command_args[0],
                "args": command_args[1:],
            }
        }
    }

    mcp = FastMCP(f"{prefix}-proxy")
    mcp.mount(create_proxy(config), namespace=prefix)
    mcp.run()

if __name__ == "__main__":
    main()
