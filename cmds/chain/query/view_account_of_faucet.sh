#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-account-of-faucet

    DESCRIPTION
    ----------------------------------------------------------------
    Displays faucet's on-chain account information at a state root hash.

    ARGS
    ----------------------------------------------------------------
    root        State root hash at a specific block height, defaults to tip.  Optional.
    "
}

function _main()
{
    local STATE_ROOT_HASH=${1:-$(get_state_root_hash)}

    local ACCOUNT_KEY=$(get_account_key "$CCTL_ACCOUNT_TYPE_FAUCET")
    local ACCOUNT_HASH=$(get_account_hash "$ACCOUNT_KEY")
    local PATH_TO_ACCOUNT_SKEY=$(get_path_to_secret_key "$CCTL_ACCOUNT_TYPE_FAUCET")
    local PURSE_UREF=$(get_main_purse_uref "$ACCOUNT_KEY" "$STATE_ROOT_HASH")
    local ACCOUNT_BALANCE=$(get_account_balance "$PURSE_UREF" "$STATE_ROOT_HASH")

    log "faucet a/c secret key    : $PATH_TO_ACCOUNT_SKEY"
    log "faucet a/c key           : $ACCOUNT_KEY"
    log "faucet a/c hash/address  : $ACCOUNT_HASH"
    log "faucet a/c purse         : $PURSE_UREF"
    log "faucet a/c purse balance : $ACCOUNT_BALANCE"
    log "faucet on-chain account  : see below"
    render_account "$CCTL_ACCOUNT_TYPE_FAUCET"
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP
unset _STATE_ROOT_HASH

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        root) _STATE_ROOT_HASH=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "$_STATE_ROOT_HASH"
fi
