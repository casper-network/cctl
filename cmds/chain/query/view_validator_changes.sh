#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-validator-changes

    DESCRIPTION
    ----------------------------------------------------------------
    Displays validator change set.
    "
}

function _main()
{
    local NODE_ADDRESS_CURL=$(get_address_of_sidecar_main_server_for_curl)

    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        --header 'Content-Type: application/json' \
        --request POST "$NODE_ADDRESS_CURL" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "info_get_validator_changes"
        }' \
    | jq '.result.changes'
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
