#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-account-of-faucet

    DESCRIPTION
    ----------------------------------------------------------------
    Displays faucet's on-chain account information at chain tip.
    "
}

function _main()
{
    local ACCOUNT_KEY=$(get_account_key "$CCTL_ACCOUNT_TYPE_FAUCET")
    local ACCOUNT_HASH=$(get_account_hash "$ACCOUNT_KEY")
    local PATH_TO_ACCOUNT_SKEY=$(get_path_to_secret_key "$CCTL_ACCOUNT_TYPE_FAUCET")
    local ACCOUNT_BALANCE=$(get_account_balance "$ACCOUNT_HASH")

    log_break
    log "a/c secret key    : $PATH_TO_ACCOUNT_SKEY"
    log "a/c key           : $ACCOUNT_KEY"
    log "a/c hash/address  : $ACCOUNT_HASH"
    log "a/c purse balance : $ACCOUNT_BALANCE"
    log_break

    source "$CCTL"/cmds/chain/query/view_account.sh account=$ACCOUNT_HASH
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
