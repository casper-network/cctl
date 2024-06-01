#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-node-restart

    DESCRIPTION
    ----------------------------------------------------------------
    Restarts a node.

    ARGS
    ----------------------------------------------------------------
    clean       Flag indicating whether node logs & data are to be wiped. Optional.
    node        Ordinal identifier of node to be stopped.
    hash        Trusted block hash from which to restart. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    clean       true
    "
}

function _main()
{
    local NODE_ID=${1}
    local CLEAN=${2}
    local TRUSTED_HASH=${3}

    log "node restart begins ... please wait"

    if [ "$(get_node_is_up "$NODE_ID")" = true ]; then
        log "... stopping node $NODE_ID"
        _stop_node "$NODE_ID"
    fi

    if [ "$CLEAN" = true ]; then
        log "... cleaning node $NODE_ID"
        _clean_node "$NODE_ID"
    fi

    log "... starting node $NODE_ID"
    _start_node "$NODE_ID"

    log "... starting node sidecar $NODE_ID"
    _start_sidecar "$NODE_ID"

    log "node restart complete"
}

function _stop_node()
{
    local NODE_ID=${1}

    local NODE_PROCESS=$(get_process_name_of_node_in_group "$NODE_ID")
    local SUPERVISORD_CONFIG=$(get_path_to_supervisord_cfg)

    supervisorctl -c "$SUPERVISORD_CONFIG" stop "$NODE_PROCESS" > /dev/null 2>&1
    sleep 1.0
}

function _clean_node()
{
    local NODE_ID=${1}

    local NODE_LOGS=$(get_path_to_node_logs "$NODE_ID")
    local NODE_STORAGE=$(get_path_to_node_storage "$NODE_ID")

    log "... cleaning logs"
    rm "$NODE_LOGS"/*.log > /dev/null 2>&1

    log "... cleaning storage"
    rm -rf "$NODE_STORAGE"/"$CCTL_NET_NAME" > /dev/null 2>&1
}

function _start_node()
{
    local NODE_ID=${1}

    local PROCESS_NAME=$(get_process_name_of_node_in_group "$NODE_ID")
    local SUPERVISORD_CONFIG=$(get_path_to_supervisord_cfg)

    supervisorctl -c "$SUPERVISORD_CONFIG" start "$PROCESS_NAME" > /dev/null 2>&1
    sleep 1.0
}

function _start_sidecar()
{
    local NODE_ID=${1}

    local PROCESS_NAME=$(get_process_name_of_node_sidecar_in_group "$NODE_ID")
    local SUPERVISORD_CONFIG=$(get_path_to_supervisord_cfg)

    supervisorctl -c "$SUPERVISORD_CONFIG" start "$PROCESS_NAME" > /dev/null 2>&1
    sleep 1.0
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _CLEAN
unset _HASH
unset _HELP
unset _NODE_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        clean) _CLEAN=${VALUE} ;;
        hash) _HASH=${VALUE} ;;
        help) _HELP="show" ;;
        node) _NODE_ID=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "$_NODE_ID" ${_CLEAN:-true} ${_HASH:-""}
fi
