#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-node-view-peer-count

    DESCRIPTION
    ----------------------------------------------------------------
    Displays count of node peers.

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
        for NODE_ID in $(seq 1 "$CCTL_COUNT_OF_NODES")
        do
            if [ $(get_is_node_up "$NODE_ID") = true ]; then
                _display_peer_count "$NODE_ID"
            fi
        done
    else
        if [ $(get_is_node_up "$NODE_ID") = true ]; then
            _display_peer_count "$NODE_ID"
        else
            log_warning "node $NODE_ID is not running"
        fi
    fi
}

function _display_peer_count()
{
    local NODE_ID=${1}
    local NODE_ADDRESS_CURL
    local NODE_PEER_COUNT
    
    NODE_ADDRESS_CURL=$(get_address_of_sidecar_main_server_for_curl "$NODE_ID")
    NODE_PEER_COUNT=$(
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            -s \
            --header 'Content-Type: application/json' \
            --request POST "$NODE_ADDRESS_CURL" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "info_get_peers"
            }' | jq '.result.peers | length'
    )

    log "node $NODE_ID peer count = $NODE_PEER_COUNT"
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
