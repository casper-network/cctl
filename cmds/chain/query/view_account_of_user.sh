#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-account-of-user

    DESCRIPTION
    ----------------------------------------------------------------
    Displays user's on-chain account information at a state root hash.

    ARGS
    ----------------------------------------------------------------
    root        State root hash at a specific block height, defaults to tip.  Optional.
    user        Ordinal identifier of a user.
    "
}

function _main()
{
    local STATE_ROOT_HASH=${2:-$(get_state_root_hash)}
    local USER_ID=${1}

    local PATH_TO_ACCOUNT_SKEY=$(get_path_to_secret_key "$CCTL_ACCOUNT_TYPE_USER" "$USER_ID")
    local ACCOUNT_KEY=$(get_account_key "$CCTL_ACCOUNT_TYPE_USER" "$USER_ID")
    local ACCOUNT_HASH=$(get_account_hash "$ACCOUNT_KEY")
    local STATE_ROOT_HASH=$(get_state_root_hash)
    local PURSE_UREF=$(get_main_purse_uref "$ACCOUNT_KEY" "$STATE_ROOT_HASH")
    local ACCOUNT_BALANCE=$(get_account_balance "$PURSE_UREF" "$STATE_ROOT_HASH")

    log "user #$USER_ID a/c secret key    : $PATH_TO_ACCOUNT_SKEY"
    log "user #$USER_ID a/c key           : $ACCOUNT_KEY"
    log "user #$USER_ID a/c hash          : $ACCOUNT_HASH"
    log "user #$USER_ID a/c purse         : $PURSE_UREF"
    log "user #$USER_ID a/c purse balance : $ACCOUNT_BALANCE"
    log "user #$USER_ID on-chain account  : see below"

    source "$CCTL"/cmds/chain/query/view_account.sh account=$ACCOUNT_HASH
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP
unset _STATE_ROOT_HASH
unset _USER_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        root) _STATE_ROOT_HASH=${VALUE} ;;
        user) _USER_ID=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "$_USER_ID" "$_STATE_ROOT_HASH"
fi
