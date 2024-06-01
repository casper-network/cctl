#!/usr/bin/env bash

#######################################
# Returns an on-chain account balance.
# Arguments:
#   Purse URef.
#   State root hash at a certain block height.
#######################################
function get_account_balance()
{
    local PURSE_UREF=${1}
    local STATE_ROOT_HASH=${2:-$(get_state_root_hash)}

    local ACCOUNT_BALANCE
    local NODE_ADDRESS=$(get_node_address_rpc)

    ACCOUNT_BALANCE=$(
        $(get_path_to_node_client) query-balance \
            --node-address "$NODE_ADDRESS" \
            --state-root-hash "$STATE_ROOT_HASH" \
            --purse-uref "$PURSE_UREF" \
            | jq '.result.balance' \
            | sed -e 's/^"//' -e 's/"$//'
        )

    echo "$ACCOUNT_BALANCE"
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

#######################################
# Returns a main purse uref.
# Globals:
#   CCTL - path to cctl home directory.
# Arguments:
#   Account key.
#   State root hash.
#######################################
function get_main_purse_uref()
{
    local ACCOUNT_HASH=${1}
    local STATE_ROOT_HASH=${2:-$(get_state_root_hash)}

    echo $(
        $(get_path_to_node_client) query-global-state \
            --node-address "$(get_node_address_rpc)" \
            --key "account-hash-$ACCOUNT_HASH" \
            --state-root-hash "$STATE_ROOT_HASH" \
            | jq '.result.stored_value.Account.main_purse' \
            | sed -e 's/^"//' -e 's/"$//'
        )
}
