#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-account

    DESCRIPTION
    ----------------------------------------------------------------
    Displays on-chain account information at a state root hash.

    ARGS
    ----------------------------------------------------------------
    account     Address/hash of account to be displayed.
    "
}

function _main()
{
    local ACCOUNT_ID=${1}

    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        --header 'Content-Type: application/json' \
        --request POST "$(get_address_of_sidecar_main_server_for_curl "1")" \
        --data-raw "$(_get_json_rpc_request_data "$ACCOUNT_ID")" \
    | jq
}

function _get_json_rpc_request_data()
{
    local ACCOUNT_ID=${1}

    echo '{
        "id": 1,
        "jsonrpc": "2.0",
        "method": "state_get_entity",
        "params": {
            "entity_identifier": {
                "AccountHash": "account-hash-'"$ACCOUNT_ID"'"
            }
        }
    }'
}


# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _ACCOUNT_ID
unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        account) _ACCOUNT_ID=${VALUE} ;;
        help) _HELP="show" ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "$_ACCOUNT_ID"
fi
