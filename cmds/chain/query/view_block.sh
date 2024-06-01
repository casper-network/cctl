#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-view-chain-block

    DESCRIPTION
    ----------------------------------------------------------------
    Renders on-chain block information.

    ARGS
    ----------------------------------------------------------------
    block       Identifier of a block (hash | height).  Optional.
    timeout     Retry duration (seconds) for unresponsive nodes.
    "
}

function _main()
{
    local BLOCK_ID=${1}

    if [ "$BLOCK_ID" ]; then
        $(get_path_to_node_client) get-block \
            --node-address "$(get_node_address_rpc)" \
            --block-identifier "$BLOCK_ID" \
            | jq '.result.block'
    else
        $(get_path_to_node_client) get-block \
            --node-address "$(get_node_address_rpc)" \
            | jq '.result.block'
    fi
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _BLOCK_ID
unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        block) _BLOCK_ID=${VALUE} ;;
        help) _HELP="show" ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main $_BLOCK_ID
fi
