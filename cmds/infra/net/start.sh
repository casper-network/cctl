#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-net-start

    DESCRIPTION
    ----------------------------------------------------------------
    Starts a network.

    NOTES
    ----------------------------------------------------------------
    Assumes that assets have been setup.
    "
}

function _main()
{
    log "network spin up begins ... please wait"

    if [ ! -e "$(get_path_net_supervisord_sock)" ]; then
        log "... starting supervisord"
        _start_supervisord
    fi

    log "... starting network"
    _start_net
}

function _start_supervisord()
{
    supervisord -c "$(get_path_net_supervisord_cfg)"
    sleep 2.0
}

function _start_net()
{
    local PATH_TO_CFG=$(get_path_net_supervisord_cfg)

    log "... ... genesis bootstrap nodes"
    supervisorctl -c "$PATH_TO_CFG" start "$CCTL_PROCESS_GROUP_1":*  > /dev/null 2>&1
    sleep 1.0

    log "... ... genesis non-bootstrap nodes"
    supervisorctl -c "$PATH_TO_CFG" start "$CCTL_PROCESS_GROUP_2":*  > /dev/null 2>&1
    sleep 1.0

    supervisorctl -c "$PATH_TO_CFG" status all || true
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main
fi

