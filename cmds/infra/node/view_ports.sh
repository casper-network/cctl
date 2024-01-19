#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-view-node-ports

    DESCRIPTION
    ----------------------------------------------------------------
    Displays ports exposed by each running node.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of node to be stopped. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    node        all
    "
}

function _main()
{
    local NODE_ID=${1}
    
    if [ "$NODE_ID" = "all" ]; then
        for NODE_ID in $(seq 1 "$(get_count_of_nodes)")
        do
            log "------------------------------------------------------------------------------------------------------"
            _display_ports "$NODE_ID"
        done
        log "------------------------------------------------------------------------------------------------------"
    else
        _display_ports "$NODE_ID"
    fi
}

function _display_ports()
{
    local NODE_ID=${1}
    local PORT_REST
    local PORT_RPC
    local PORT_SSE
    local PORT_SPECULATIVE_EXEC

    PORT_BIND=$(get_node_port_bind "$NODE_ID")
    PORT_REST=$(get_node_port_rest "$NODE_ID")
    PORT_RPC=$(get_node_port_rpc "$NODE_ID")
    PORT_SSE=$(get_node_port_sse "$NODE_ID")
    PORT_SPECULATIVE_EXEC=$(get_node_port_speculative_exec "$NODE_ID")

    log "node-$NODE_ID -> CONSENSUS @ $PORT_BIND :: RPC @ $PORT_RPC :: REST @ $PORT_REST :: SSE @ $PORT_SSE :: SPECULATIVE_EXEC @ $PORT_SPECULATIVE_EXEC"
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
    _main "${_NODE_ID:-"all"}"
fi
