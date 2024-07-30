#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-view-chain-block

    DESCRIPTION
    ----------------------------------------------------------------
    Renders on-chain block information.

    ARGS
    ----------------------------------------------------------------
    block       Identifier of a block (hash | height).  Optional.
    timeout     Retry duration (seconds) for unresponsive nodes.
    "
}

function _main()
{
    local BLOCK_ID=${1}

    if [ "$BLOCK_ID" ]; then
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --header 'Content-Type: application/json' \
            --request POST "$(get_address_of_sidecar_main_server_for_curl "$NODE_ID")" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "chain_get_block",
                "params": {
                    "block_identifier": {
                        "Hash": "'"$BLOCK_ID"'"
                    }
                }
            }' \
        | jq '.result.block_with_signatures'
    else
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --header 'Content-Type: application/json' \
            --request POST "$(get_address_of_sidecar_main_server_for_curl "$NODE_ID")" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "chain_get_block"
            }' \
        | jq '.result.block_with_signatures'
    fi
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _BLOCK_ID
unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        block) _BLOCK_ID=${VALUE} ;;
        help) _HELP="show" ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main $_BLOCK_ID
fi
