#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-sidecar-stop

    DESCRIPTION
    ----------------------------------------------------------------
    Stops a sidecar.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of node sidecar to be stopped.
    "
}

function _main()
{
    local NODE_ID=${1}

    if [ "$(get_is_net_up)" = true ]; then
        if [ "$(get_is_sidecar_up "$NODE_ID")" = true ]; then
            log "sidecar $NODE_ID :: stopping ... please wait"
            _stop_sidecar "$NODE_ID"
            log "sidecar $NODE_ID :: stopped"
        else
            log_warning "sidecar $NODE_ID is already stopped"
        fi
    else
        log_warning "network not running - no need to stop sidecar"
    fi
}

function _stop_sidecar()
{
    local NODE_ID=${1}

    local PROCESS_NAME=$(get_process_name_of_sidecar_in_group "$NODE_ID")
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_supervisord_cfg)

    supervisorctl -c "$PATH_TO_SUPERVISOR_CONFIG" stop "$PROCESS_NAME" > /dev/null 2>&1
    sleep 1.0
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP
unset _NODE_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        node) _NODE_ID=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "$_NODE_ID"
fi
