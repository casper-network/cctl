#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-account

    DESCRIPTION
    ----------------------------------------------------------------
    Displays on-chain account information at a state root hash.

    ARGS
    ----------------------------------------------------------------
    account     Key of account to be displayed.
    root        State root hash at a specific block height, defaults to tip.  Optional.
    "
}

function _main()
{
    local ACCOUNT_KEY=${1}
    local STATE_ROOT_HASH=${2}

    $(get_path_to_client) query-global-state \
        --node-address "$(get_node_address_rpc)" \
        --state-root-hash "${STATE_ROOT_HASH:-$(get_state_root_hash)}" \
        --key "$ACCOUNT_KEY" \
        | jq '.result'
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _ACCOUNT_KEY
unset _HELP
unset _STATE_ROOT_HASH

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        account) _ACCOUNT_KEY=${VALUE} ;;
        help) _HELP="show" ;;
        root) _STATE_ROOT_HASH=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "$_ACCOUNT_KEY" "$_STATE_ROOT_HASH"
fi
