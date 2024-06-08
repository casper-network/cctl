#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-account-of-validator

    DESCRIPTION
    ----------------------------------------------------------------
    Displays validator's on-chain account information at chain tip.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of a node.
    "
}

function _main()
{
    local NODE_ID=${1}

    local PATH_TO_ACCOUNT_SKEY=$(get_path_to_secret_key "$CCTL_ACCOUNT_TYPE_NODE" "$NODE_ID")
    local ACCOUNT_KEY=$(get_account_key "$CCTL_ACCOUNT_TYPE_NODE" "$NODE_ID")
    local ACCOUNT_HASH=$(get_account_hash "$ACCOUNT_KEY")
    local ACCOUNT_BALANCE=$(get_account_balance "$ACCOUNT_HASH")

    log_break
    log "validator #$NODE_ID a/c secret key    : $PATH_TO_ACCOUNT_SKEY"
    log "validator #$NODE_ID a/c key           : $ACCOUNT_KEY"
    log "validator #$NODE_ID a/c hash          : $ACCOUNT_HASH"
    log "validator #$NODE_ID a/c balance       : $ACCOUNT_BALANCE"
    log_break

    source "$CCTL"/cmds/chain/query/view_account.sh account=$ACCOUNT_HASH
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
    _main "$_NODE_ID"
fi
