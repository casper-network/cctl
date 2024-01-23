#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-node-clean

    DESCRIPTION
    ----------------------------------------------------------------
    Cleans node logs & data.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of node to be cleaned.
    "
}

function _main()
{
    local NODE_ID=${1}

    if [ "$(get_node_is_up "$NODE_ID")" = true ]; then
        log "Node $NODE_ID is currently running ... please stop prior to cleaning."
    else
        log "cleaning node $NODE_ID ... please wait"
        _clean_node "$NODE_ID"
        log "node $NODE_ID cleaned"
    fi
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
