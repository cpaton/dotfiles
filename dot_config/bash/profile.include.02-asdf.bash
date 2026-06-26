#! /usr/bin/env bash

if [[ ":$PATH:" != *":$HOME/.asdf/shims:"* ]]; then
    export PATH="$HOME/.asdf/shims:$PATH"
fi
