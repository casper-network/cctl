#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-view-chain-auction-info

    DESCRIPTION
    ----------------------------------------------------------------
    Renders on-chain auction information.
    "
}

function _main()
{
    local NODE_ID=${1}
    local NODE_ADDRESS_CURL=$(get_address_of_sidecar_main_server_for_curl "$NODE_ID")

    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        --header 'Content-Type: application/json' \
        --request POST "$NODE_ADDRESS_CURL" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "state_get_auction_info"
        }' | jq '.result.auction_state'
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
    _main "${_NODE_ID:-"1"}"
fi
