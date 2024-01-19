#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-account-balance

    DESCRIPTION
    ----------------------------------------------------------------
    Displays an account balance at a state root hash.

    ARGS
    ----------------------------------------------------------------
    root        State root hash at a specific block height, defaults to tip.  Optional.
    "
}

function _main()
{
    echo 123
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
