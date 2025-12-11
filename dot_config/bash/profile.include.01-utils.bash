#! /usr/bin/env bash

is_ssh_session() {
    [[ -v SSH_CONNECTION || -v SSH_CLIENT ]]
}
