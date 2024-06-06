#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-net-stop

    DESCRIPTION
    ----------------------------------------------------------------
    Stops a network by halting all nodes.
    "
}

function _main()
{
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_supervisord_cfg)
    local PATH_TO_SUPERVISOR_SOCKET=$(get_path_to_supervisord_sock)

    if [ -e "$PATH_TO_SUPERVISOR_SOCKET" ]; then
        log "stopping network ... please wait"
        supervisorctl -c "$PATH_TO_SUPERVISOR_CONFIG" shutdown > /dev/null 2>&1 || true
        sleep 2.0
    else
        log "network not running - no need to stop"
    fi
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
