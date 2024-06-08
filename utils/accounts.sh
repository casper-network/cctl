#!/usr/bin/env bash

#######################################
# Returns an on-chain account balance.
# Arguments:
#   Identifier of an account.
#######################################
function get_account_balance()
{
    local ACCOUNT_ID=${1}

    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        --header 'Content-Type: application/json' \
        --request POST "$(get_address_of_sidecar_main_server_for_curl "1")" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "query_balance",
            "params": {
                "purse_identifier": {
                    "main_purse_under_account_hash": "account-hash-'"$ACCOUNT_ID"'"
                }
            }
        }' \
    | jq '.result.balance' \
    | sed -e 's/^"//' -e 's/"$//'
}

#######################################
# Returns an on-chain account hash.
# Arguments:
#   Key of account.
#   Type of account key.
#######################################
function get_account_hash()
{
    local ACCOUNT_KEY=${1}
    local ACCOUNT_PBK=${ACCOUNT_KEY:2}

    local SCRIPT=(
        "import hashlib;"
        "as_bytes=bytes('ed25519', 'utf-8') + bytearray(1) + bytes.fromhex('$ACCOUNT_PBK');"
        "h=hashlib.blake2b(digest_size=32);"
        "h.update(as_bytes);"
        "print(h.digest().hex());"
     )

    python3 -c "${SCRIPT[*]}"
}

#######################################
# Returns an account key.
# Globals:
#   CCTL_ACCOUNT_TYPE_FAUCET - faucet account type.
#   CCTL_ACCOUNT_TYPE_NODE - node account type.
#   CCTL_ACCOUNT_TYPE_USER - user account type.
# Arguments:
#   Account type (node | user | faucet).
#   Account ordinal identifier (optional).
#######################################
function get_account_key()
{
    local ACCOUNT_TYPE=${1}
    local ACCOUNT_IDX=${2}

    if [ "$ACCOUNT_TYPE" = "$CCTL_ACCOUNT_TYPE_FAUCET" ]; then
        cat "$(get_path_to_assets)"/faucet/public_key_hex
    elif [ "$ACCOUNT_TYPE" = "$CCTL_ACCOUNT_TYPE_NODE" ]; then
        cat "$(get_path_to_node "$ACCOUNT_IDX")"/keys/public_key_hex
    elif [ "$ACCOUNT_TYPE" = "$CCTL_ACCOUNT_TYPE_USER" ]; then
        cat "$(get_path_to_user "$ACCOUNT_IDX")"/public_key_hex
    fi
}
