#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-view-chain-tx

    DESCRIPTION
    ----------------------------------------------------------------
    Renders on-chain transaction information.

    ARGS
    ----------------------------------------------------------------
    tx      Identifier of a transaction (hash).
    "
}

function _main()
{
    local TX_ID=${1}
    local NODE_ADDRESS_CURL=$(get_address_of_sidecar_main_server_for_curl)

    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        --header 'Content-Type: application/json' \
        --request POST "$NODE_ADDRESS_CURL" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "info_get_transaction",
            "params": {
                "transaction_hash": {
                    "Version1": "'"$TX_ID"'"
                }
            }
        }' \
    | jq
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP
unset _TX_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        tx) _TX_ID=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main $_TX_ID
fi
