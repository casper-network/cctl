#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-validator-changes

    DESCRIPTION
    ----------------------------------------------------------------
    Displays validator change set.

    ARGS
    ----------------------------------------------------------------
    node        Identifier of a node. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    node        1
    "
}

function _main()
{
    local NODE_ID=${1}

    echo "$(get_node_address_rpc "$NODE_ID")"

    $(get_path_to_node_client) get-validator-changes \
        --node-address "$(get_node_address_rpc "$NODE_ID")" \
        | jq '.result.changes'
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
    _main "${_NODE_ID:-"1"}"
fi
