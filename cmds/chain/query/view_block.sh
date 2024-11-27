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
    local NODE_ID=${1}
    local BLOCK_ID=${2}
    local NODE_ADDRESS_CURL=$(get_address_of_sidecar_main_server_for_curl "$NODE_ID")
    local is_block_height

    if [ "$BLOCK_ID" ]; then
        if [ $(get_is_numeric "$BLOCK_ID") = true ]; then
            curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
                --header 'Content-Type: application/json' \
                --request POST "$NODE_ADDRESS_CURL" \
                --data-raw '{
                    "id": 1,
                    "jsonrpc": "2.0",
                    "method": "chain_get_block",
                    "params": {
                        "block_identifier": {
                            "Height": '"$BLOCK_ID"'
                        }
                    }
                }' \
            | jq '.result'
        else
            curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
                --header 'Content-Type: application/json' \
                --request POST "$NODE_ADDRESS_CURL" \
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
            | jq '.result'
        fi
    else
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --header 'Content-Type: application/json' \
            --request POST "$NODE_ADDRESS_CURL" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "chain_get_block"
            }' \
        | jq '.result'
    fi
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _BLOCK_ID
unset _HELP
unset _NODE_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        block) _BLOCK_ID=${VALUE} ;;
        help) _HELP="show" ;;
        node) _NODE_ID=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "${_NODE_ID:-"1"}" "${_BLOCK_ID:-""}"
fi
