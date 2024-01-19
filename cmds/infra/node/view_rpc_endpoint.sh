#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-view-rpc-endpoint

    DESCRIPTION
    ----------------------------------------------------------------
    Prints to stdout information regarding node JSON RPC endpoint(s).
    "
}

function _main()
{
    local ENDPOINT=${1}

    if [ "$ENDPOINT" = "all" ]; then
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --header 'Content-Type: application/json' \
            --request POST "$(get_node_address_rpc_for_curl)" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "rpc.discover"
            }' | jq '.result.schema.methods[].name'
    else
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --header 'Content-Type: application/json' \
            --request POST "$(get_node_address_rpc_for_curl)" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "rpc.discover"
            }' | jq '.result.schema.methods[] | select(.name == "'"$ENDPOINT"'")'
    fi
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _ENDPOINT
unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        endpoint) _ENDPOINT=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "${_ENDPOINT:-"all"}"
fi
