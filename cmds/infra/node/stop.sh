#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-node-stop

    DESCRIPTION
    ----------------------------------------------------------------
    Stops a node.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of node to be stopped.
    "
}

function _main()
{
    local NODE_ID=${1}

    if [ "$(get_is_net_up)" = true ]; then
        if [ "$(get_is_node_up "$NODE_ID")" = true ]; then
            log "stopping node $NODE_ID ... please wait"
            _stop_node "$NODE_ID"
            log "$NODE_ID stopped"
        else
            log_warning "node $NODE_ID is already stopped"
        fi
    else
        log_warning "network not running - no need to stop node"
    fi
}

function _stop_node()
{
    local NODE_ID=${1}

    local NODE_PROCESS_NAME=$(get_process_name_of_node_in_group "$NODE_ID")
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_supervisord_cfg)

    supervisorctl -c "$PATH_TO_SUPERVISOR_CONFIG" stop "$NODE_PROCESS_NAME" > /dev/null 2>&1
    sleep 1.0

    log "... node $NODE_ID stopped"
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
