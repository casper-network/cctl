#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-view-chain-block-transfers

    DESCRIPTION
    ----------------------------------------------------------------
    Renders set of transfers within a block.

    ARGS
    ----------------------------------------------------------------
    block       Identifier of a block (hash | height).  Optional.
    "
}

function _main()
{
    local BLOCK_ID=${1}

    if [ "$BLOCK_ID" ]; then
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --header 'Content-Type: application/json' \
            --request POST "$(get_address_of_sidecar_main_server_for_curl)" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "chain_get_block_transfers",
                "params": {
                    "block_identifier": {
                        "Hash": "'"$BLOCK_ID"'"
                    }
                }
            }' | jq '.result.transfers'
    else
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --header 'Content-Type: application/json' \
            --request POST "$(get_address_of_sidecar_main_server_for_curl)" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "chain_get_block_transfers"
            }' | jq '.result.transfers'
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
