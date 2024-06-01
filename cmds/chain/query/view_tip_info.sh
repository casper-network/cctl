#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-tip-info

    DESCRIPTION
    ----------------------------------------------------------------
    Displays chain tip information at specific node(s).
    "
}

function _main()
{
    local NODE_ID

    for NODE_ID in $(seq 1 "$CCTL_COUNT_OF_NODES")
    do
        if [ $(get_is_node_up "$NODE_ID") = true ]; then
            log_break
            log "TIP INFO @ NODE-$NODE_ID"
            log_break
            _render $NODE_ID
        fi
    done
}

function _render()
{
    local NODE_ID=${1}
    local NODE_ADDRESS_CURL=$(get_node_address_rpc_for_curl "$NODE_ID")
    local NODE_API_RESPONSE
    
    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        --header 'Content-Type: application/json' \
        --request POST "$NODE_ADDRESS_CURL" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "info_get_status"
        }' \
        | jq '.result.last_added_block_info'
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main
fi
