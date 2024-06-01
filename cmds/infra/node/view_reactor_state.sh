#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-node-view-reactor-state

    DESCRIPTION
    ----------------------------------------------------------------
    Displays reactor status at specified node(s).

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
            if [ $(get_node_is_up "$NODE_ID") = true ]; then
                echo "------------------------------------------------------------------------------------------------------------------------------------"
                _display_reactor_state "$NODE_ID"
            fi
        done
        echo "------------------------------------------------------------------------------------------------------------------------------------"
    else
        if [ $(get_node_is_up "$NODE_ID") = true ]; then
            _display_reactor_state "$NODE_ID"
        else
            log_warning "node $NODE_ID is not running"
        fi
    fi
}

function _display_reactor_state()
{
    local NODE_ID=${1}
    local NODE_ADDRESS_CURL=$(get_node_address_rpc_for_curl "$NODE_ID")
    local NODE_API_RESPONSE
    
    NODE_API_RESPONSE=$(
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES --header 'Content-Type: application/json' \
            --request POST "$NODE_ADDRESS_CURL" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "info_get_status"
            }' \
            | jq '.result.reactor_state' \
            | sed -e 's/^"//' -e 's/"$//'
    )

    if [ -z "$NODE_API_RESPONSE" ]; then
        log "node #$NODE_ID reactor state: N/A"
    else
        log "node #$NODE_ID reactor state = $NODE_API_RESPONSE"
    fi
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
