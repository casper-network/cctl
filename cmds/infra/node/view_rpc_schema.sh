#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-view-rpc-schema

    DESCRIPTION
    ----------------------------------------------------------------
    Prints to stdout the node JSON RPC schema.
    "
}

function _main()
{
    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        --header 'Content-Type: application/json' \
        --request POST "$(get_node_address_rpc_for_curl)" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "rpc.discover"
        }' | jq '.result.schema'
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
