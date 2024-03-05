#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-account-address

    DESCRIPTION
    ----------------------------------------------------------------
    Displays an account hash from a given public key

    ARGS
    ----------------------------------------------------------------
    key        Asymmetric public key associated with an on-chain account.
    "
}

function _main()
{
    local PUBLIC_KEY=${1}
    local ADDRESS
    
    ADDRESS=$($(get_path_to_client) account-address --public-key "$PUBLIC_KEY")
    ADDRESS=${ADDRESS:13}

    log_break
    log "a/c public key  : $PUBLIC_KEY"
    log "a/c address     : $ADDRESS"
    log_break
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP
unset _KEY

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        key) _KEY=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "$_KEY"
fi
