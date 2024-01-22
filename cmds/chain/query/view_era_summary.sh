#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-era-summary

    DESCRIPTION
    ----------------------------------------------------------------
    Displays era summary data at a specified node.

    ARGS
    ----------------------------------------------------------------
    block       Identifier of a block (hash | height). Optional.
    node        Identifier of a node. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    node        1
    "
}

function _main()
{
    local NODE_ID=${1}
    local BLOCK_ID=${2}

    $(get_path_to_client) get-era-summary \
        --node-address "$(get_node_address_rpc "$NODE_ID")" \
        --block-identifier "$BLOCK_ID" \
        | jq '.result'
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _BLOCK_ID
unset _HELP
unset _NODE_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        block) _BLOCK_ID=${VALUE} ;;
        help) _HELP="show" ;;
        node) _NODE_ID=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "${_NODE_ID:-"1"}" \
          "${_BLOCK_ID:-""}"
fi
