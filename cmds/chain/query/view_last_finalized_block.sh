#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-view-last-finalized-block.

    DESCRIPTION
    ----------------------------------------------------------------
    Displays chain's last finialized block.
    "
}

function _main()
{
    local NODE_ID
    local NODE_LFB_HASH

    for NODE_ID in $(seq 1 "$CCTL_COUNT_OF_NODES")
    do
        if [ $(get_is_node_up "$NODE_ID") = true ]; then
            NODE_LFB=$(get_chain_latest_block_hash "$NODE_ID")
            log "last finalized block hash @ node-$NODE_ID = ${NODE_LFB:-'N/A'}"
        fi
    done
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
