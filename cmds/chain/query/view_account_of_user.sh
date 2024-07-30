#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-account-of-user

    DESCRIPTION
    ----------------------------------------------------------------
    Displays user's on-chain account information at chain tip.

    ARGS
    ----------------------------------------------------------------
    user        Ordinal identifier of a user.
    "
}

function _main()
{
    local USER_ID=${1}

    local PATH_TO_ACCOUNT_SKEY=$(get_path_to_secret_key "$CCTL_ACCOUNT_TYPE_USER" "$USER_ID")
    local ACCOUNT_KEY=$(get_account_key "$CCTL_ACCOUNT_TYPE_USER" "$USER_ID")
    local ACCOUNT_HASH=$(get_account_hash "$ACCOUNT_KEY")
    local ACCOUNT_BALANCE=$(get_account_balance "$ACCOUNT_HASH")

    log_break
    log "a/c secret key    : $PATH_TO_ACCOUNT_SKEY"
    log "a/c key           : $ACCOUNT_KEY"
    log "a/c hash          : $ACCOUNT_HASH"
    log "a/c balance       : $ACCOUNT_BALANCE"
    log_break

    source "$CCTL"/cmds/chain/query/view_account.sh account=$ACCOUNT_HASH
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP
unset _USER_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        user) _USER_ID=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "$_USER_ID"
fi
