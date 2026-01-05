#! /usr/bin/env bash

_ssh_dir="$HOME/.ssh"
_symlink_env="$_ssh_dir/ssh-agent.env"

(
    _manage_ssh_agents() {
        local _local_env="$_ssh_dir/ssh-agent-local.env"
        local _local_socket="$_ssh_dir/ssh-agent-local.sock"
        local _remote_env="$_ssh_dir/ssh-agent-remote.env"
        local _symlink_socket="$_ssh_dir/ssh-agent.sock"
        local _symlink_env="$_ssh_dir/ssh-agent.env"
        local _bitwarden_socket="$HOME/.bitwarden-ssh-agent.sock"
        local _bitwarden_env="$_ssh_dir/bitwarden-ssh-agent.env"
        local _using_local_agent=true

        mkdir --parents "$_ssh_dir"

        # If an SSH session with agent forwarding use that for our ssh-agent
        if is_ssh_session && [[ -n "$SSH_AUTH_SOCK" && -S "$SSH_AUTH_SOCK" ]]; then
            _using_local_agent=false
            ln --symbolic --force "$SSH_AUTH_SOCK" "$_symlink_socket"

            printf 'export SSH_AUTH_SOCK=%q\nexport SSH_AGENT_PID=%q\n' "$SSH_AUTH_SOCK" "$SSH_AGENT_PID" > "$_remote_env"
            ln --symbolic --force "$_remote_env" "$_symlink_env"
        fi

        # if bitwarden ssh-agent is available use that
        if [[ -S "$_bitwarden_socket" ]]; then
            _using_local_agent=false
            ln --symbolic --force "$_bitwarden_socket" "$_symlink_socket"

            printf 'export SSH_AUTH_SOCK=%q\n' "$_bitwarden_socket" > "$_bitwarden_env"
            ln --symbolic --force "$_bitwarden_env" "$_symlink_env"
        fi

        # start a local agent if not already running
        local _start_local_agent=false
        if [[ -f "$_local_env" ]]; then
            # shellcheck source=/dev/null
            source "$_local_env"

            kill -0 "$SSH_AGENT_PID" 2>/dev/null
            local _agent_is_running=$?

            if [[ ! -S "$SSH_AUTH_SOCK" ]] || [[ $_agent_is_running -ne 0 ]]; then
               _start_local_agent=true
            fi
        else
            _start_local_agent=true
        fi

        if $_start_local_agent; then
            rm --force "$_local_socket"
            eval "$(ssh-agent -a "$_local_socket" -s)" >/dev/null
            printf 'export SSH_AUTH_SOCK=%q\nexport SSH_AGENT_PID=%q\n' "$SSH_AUTH_SOCK" "$SSH_AGENT_PID" > "$_local_env"
        fi

        # if ssh-agent not provided by SSH session, use local agent
        if $_using_local_agent; then
            ln --symbolic --force "$_local_socket" "$_symlink_socket"
            ln --symbolic --force "$_local_env" "$_symlink_env"
        fi
    }

    _manage_ssh_agents
)

# If no agent provided (SSH_AUTH_SOCK is empty), load the local agent settings
if [[ -z "$SSH_AUTH_SOCK" ]] && [[ -f "$_symlink_env" ]]; then
    # shellcheck source=/dev/null
    echo "Sourcing local ssh-agent environment from $_symlink_env"
    source "$_symlink_env"
fi

unset _ssh_dir _symlink_env
