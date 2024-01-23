#!/usr/bin/env bash

#######################################
# Renders an account.
# Globals:
#   CCTL - path to cctl home directory.
# Arguments:
#   Account type (node | user | faucet).
#   Account ordinal identifier (optional).
#######################################
function render_account()
{
    local ACCOUNT_TYPE=${1}
    local ACCOUNT_IDX=${2}

    local ACCOUNT_KEY=$(get_account_key "$ACCOUNT_TYPE" "$ACCOUNT_IDX")
    local STATE_ROOT_HASH=$(get_state_root_hash)

    source "$CCTL"/cmds/chain/query/view_account.sh \
        root-hash="$STATE_ROOT_HASH" \
        account-key="$ACCOUNT_KEY"
}

#######################################
# Renders an account balance.
# Globals:
#   CCTL - path to cctl home directory.
# Arguments:
#   Account type (node | user | faucet).
#   Account ordinal identifier (optional).
#######################################
function render_account_balance()
{
    local ACCOUNT_TYPE=${1}
    local ACCOUNT_IDX=${2}

    local ACCOUNT_KEY=$(get_account_key "$ACCOUNT_TYPE" "$ACCOUNT_IDX")
    local ACCOUNT_PREFIX=$(get_account_prefix "$ACCOUNT_TYPE" "$ACCOUNT_IDX")
    local STATE_ROOT_HASH=$(get_state_root_hash)
    local PURSE_UREF=$(get_main_purse_uref "$ACCOUNT_KEY" "$STATE_ROOT_HASH")

    source "$CCTL"/cmds/chain/query/view_account_balance.sh \
        root-hash="$STATE_ROOT_HASH" \
        purse-uref="$PURSE_UREF" \
        prefix="$ACCOUNT_PREFIX"
}

#######################################
# Renders an account hash.
# Arguments:
#   Account type (node | user | faucet).
#   Account ordinal identifier (optional).
#######################################
function render_account_hash()
{
    local ACCOUNT_TYPE=${1}
    local ACCOUNT_IDX=${2}   

    local ACCOUNT_KEY=$(get_account_key "$ACCOUNT_TYPE" "$ACCOUNT_IDX")
    local ACCOUNT_HASH=$(get_account_hash "$ACCOUNT_KEY")
    local ACCOUNT_PREFIX=$(get_account_prefix "$ACCOUNT_TYPE" "$ACCOUNT_IDX")

    log "$ACCOUNT_PREFIX.account-hash = $ACCOUNT_HASH"
}

#######################################
# Renders an account key.
# Globals:
#   CCTL_ACCOUNT_TYPE_FAUCET - faucet account type.
#   CCTL_ACCOUNT_TYPE_NODE - node account type.
#   CCTL_ACCOUNT_TYPE_USER - user account type.
# Arguments:
#   Account type (node | user | faucet).
#   Account ordinal identifier (optional).
#######################################
function render_account_key()
{
    local ACCOUNT_TYPE=${1}
    local ACCOUNT_IDX=${2}  

    local ACCOUNT_KEY=$(get_account_key "$ACCOUNT_TYPE" "$ACCOUNT_IDX")
    local ACCOUNT_PREFIX=$(get_account_prefix "$ACCOUNT_TYPE" "$ACCOUNT_IDX")

    log "$ACCOUNT_PREFIX.account-key = $ACCOUNT_KEY"
}

#######################################
# Renders an account's main purse uref.
# Globals:
#   CCTL_ACCOUNT_TYPE_FAUCET - faucet account type.
#   CCTL_ACCOUNT_TYPE_NODE - node account type.
#   CCTL_ACCOUNT_TYPE_USER - user account type.
# Arguments:
#   Account type (node | user | faucet).
#   Account ordinal identifier (optional).
#   State root hash (optional).
#######################################
function render_account_main_purse_uref()
{
    local ACCOUNT_TYPE=${1}
    local ACCOUNT_IDX=${2}  
    local STATE_ROOT_HASH=${3:-$(get_state_root_hash)}

    local ACCOUNT_KEY=$(get_account_key "$ACCOUNT_TYPE" "$ACCOUNT_IDX")
    local ACCOUNT_PREFIX=$(get_account_prefix "$ACCOUNT_TYPE" "$ACCOUNT_IDX")
    local PURSE_UREF=$(get_main_purse_uref "$ACCOUNT_KEY" "$STATE_ROOT_HASH")

    log "$ACCOUNT_PREFIX.main-purse-uref = $PURSE_UREF"
}

#######################################
# Renders an account secret key path.
# Arguments:
#   Account type (node | user | faucet).
#   Account ordinal identifier (optional).
#######################################
function render_account_secret_key()
{
    local ACCOUNT_TYPE=${1}
    local ACCOUNT_IDX=${2}    

    local ACCOUNT_PREFIX=$(get_account_prefix "$ACCOUNT_TYPE" "$ACCOUNT_IDX")
    local PATH_TO_KEY=$(get_path_to_secret_key "$ACCOUNT_TYPE" "$ACCOUNT_IDX")

    log "$ACCOUNT_PREFIX.secret-key-path = $PATH_TO_KEY"
}

#######################################
# Renders a state root hash at a certain node.
# Globals:
#   CCTL - path to cctl home directory.
# Arguments:
#   Node ordinal identifier.
#   Hash of block at which to return associated state root hash.
#######################################
function render_chain_state_root_hash()
{
    local NODE_ID=${1}
    local BLOCK_HASH=${2}

    local NODE_IS_UP=$(get_node_is_up "$NODE_ID")
    local STATE_ROOT_HASH

    if [ "$NODE_IS_UP" = true ]; then
        STATE_ROOT_HASH=$(get_state_root_hash "$NODE_ID" "$BLOCK_HASH")
    fi

    log "state root hash @ node-$NODE_ID = ${STATE_ROOT_HASH:-'N/A'}"
}

#######################################
# Renders a last finalized block hash at a certain node.
# Globals:
#   CCTL - path to cctl home directory.
# Arguments:
#   Node ordinal identifier.
#######################################
function render_last_finalized_block_hash()
{
    local NODE_ID=${1}

    local NODE_IS_UP=$(get_node_is_up "$NODE_ID")
    local LFB_HASH

    if [ "$NODE_IS_UP" = true ]; then
        LFB_HASH=$(get_chain_latest_block_hash "$NODE_ID")
    fi

    log "last finalized block hash @ node-$NODE_ID = ${LFB_HASH:-'N/A'}"
}
