#! /usr/bin/env bash

# Add to ~/.bashrc (runs for all interactive shells)
# if [ -f "$HOME/.config/bash/profile.bash" ]; then
#     . "$HOME/.config/bash/profile.bash"
# fi

# Directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find all matching files, sort them, and loop safely
while IFS= read -r file; do
    # echo "Sourcing $file"
    source "$file"
done < <(find -L "$SCRIPT_DIR" -maxdepth 1 -type f -name 'profile.include.*.bash' | sort)

