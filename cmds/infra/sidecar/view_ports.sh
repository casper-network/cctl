#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-sidecar-view-ports

    DESCRIPTION
    ----------------------------------------------------------------
    Displays ports exposed by each running sidecar.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of a node. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    node        all
    "
}

function _main()
{
    local NODE_ID=${1}

    if [ "$NODE_ID" = "all" ]; then
        log "------------------------------------------------------------------------------------------------------"
        log "SIDECAR PORTS"
        log "------------------------------------------------------------------------------------------------------"
        for NODE_ID in $(seq 1 "$CCTL_COUNT_OF_NODES")
        do
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

    local PORT_NODE_BINARY=$(get_port_of_node_binary_server "$NODE_ID")
    local PORT_SIDECAR_MAIN=$(get_port_of_sidecar_main_server  "$NODE_ID")
    local PORT_SIDECAR_SPEC_EXEC=$(get_port_of_sidecar_speculative_exec_server "$NODE_ID")

    log "SIDECAR-$NODE_ID"
    log "    NODE-CLIENT -> $PORT_NODE_BINARY"
    log "    MAIN-RPC ----> $PORT_SIDECAR_MAIN"
    log "    SPEC-EXEC ---> $PORT_SIDECAR_SPEC_EXEC"
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
