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

    local API_ENDPOINT="$(get_address_of_node_rest_server "$NODE_ID")"/status
    local API_RESPONSE=$(
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES --header 'Content-Type: application/json' \
            --location \
            --request GET "$API_ENDPOINT" \
            | jq '.peers | length'
    )

    log "node $NODE_ID peer count = $API_RESPONSE"
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
