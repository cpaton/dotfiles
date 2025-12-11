#! /usr/bin/env bash

_ssh_dir="$HOME/.ssh"
_local_env="$_ssh_dir/ssh-agent-local.env"

(
    _manage_ssh_agents() {
        local _remote_env="$_ssh_dir/ssh-agent-remote.env"
        local _local_socket="$_ssh_dir/ssh-agent-local.sock"
        local _symlink_socket="$_ssh_dir/ssh-agent.sock"
        local _using_remote_agent=false

        mkdir --parents "$_ssh_dir"

        # If an SSH session with agent forwarding use that for our ssh-agent
        if is_ssh_session && [[ -n "$SSH_AUTH_SOCK" && -S "$SSH_AUTH_SOCK" ]]; then
            _using_remote_agent=true
            ln --symbolic --force "$SSH_AUTH_SOCK" "$_symlink_socket"

            printf 'export SSH_AUTH_SOCK=%q\nexport SSH_AGENT_PID=%q\n' "$SSH_AUTH_SOCK" "$SSH_AGENT_PID" > "$_remote_env"
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
        if ! $_using_remote_agent; then
            ln --symbolic --force "$_local_socket" "$_symlink_socket"
        fi
    }

    _manage_ssh_agents
)

# If no agent provided (SSH_AUTH_SOCK is empty), load the local agent settings
if [[ -z "$SSH_AUTH_SOCK" ]] && [[ -f "$_local_env" ]]; then
    # shellcheck source=/dev/null
    source "$_local_env"
fi

unset _ssh_dir _local_env
