#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-state-root-hash

    DESCRIPTION
    ----------------------------------------------------------------
    Displays chain state root hash at specified node(s).

    ARGS
    ----------------------------------------------------------------
    block       Identifier of a block (hash | height). Optional.
    "
}

function _main()
{
    local BLOCK_ID=${1}

    local NODE_ID
    local NODE_SRH

    for NODE_ID in $(seq 1 "$(get_count_of_nodes)")
    do
        if [ $(get_node_is_up "$NODE_ID") = true ]; then
            NODE_SRH=$(get_state_root_hash "$NODE_ID" "$BLOCK_ID")
            log "state root @ node-$NODE_ID = ${NODE_SRH:-'N/A'}"
        fi
    done
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
    _main "${_BLOCK_ID:-""}"
fi
