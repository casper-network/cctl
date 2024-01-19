#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-view-node-peers

    DESCRIPTION
    ----------------------------------------------------------------
    Displays node peers.

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
        for NODE_ID in $(seq 1 "$(get_count_of_nodes)")
        do
            if [ $(get_node_is_up "$NODE_ID") = true ]; then
                _display_peers "$NODE_ID"
            fi
        done
    else
        if [ $(get_node_is_up "$NODE_ID") = true ]; then
            _display_peers "$NODE_ID"
        else
            log_warning "node $NODE_ID is not running"
        fi
    fi
}

function _display_peers()
{
    local NODE_ID=${1}
    local NODE_ADDRESS_CURL
    local NODE_API_RESPONSE
    
    NODE_ADDRESS_CURL=$(get_node_address_rpc_for_curl "$NODE_ID")
    NODE_API_RESPONSE=$(
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            -s \
            --header 'Content-Type: application/json' \
            --request POST "$NODE_ADDRESS_CURL" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "info_get_peers"
            }' | jq '.result.peers | sort_by(.address)'
    )

    log "------------------------------------------------------------------------------------------------------"
    log "peers of node $NODE_ID"
    log "------------------------------------------------------------------------------------------------------"
    echo "$NODE_API_RESPONSE" | jq
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
