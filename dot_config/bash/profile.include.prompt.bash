#! /usr/bin/env bash

# if we can't find oh-my-posh exit early
if ! command -v oh-my-posh &> /dev/null; then
    return
fi

# Run oh-my-posh using config ~/.config/oh-my-posh/shell.omp.yaml
eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/shell.omp.yaml)"
