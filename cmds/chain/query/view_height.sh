#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-view-chain-height

    DESCRIPTION
    ----------------------------------------------------------------
    Displays current chain height at running nodes.

    ARGS
    ----------------------------------------------------------------
    timeout     Timeout (seconds) to await retry when querying unresponsive node(s).  Optional.

    DEFAULTS
    ----------------------------------------------------------------
    timeout     2.0 seconds
    "
}

function _main()
{
    local TIMEOUT_SEC=${1}

    for NODE_ID in $(seq 1 "$(get_count_of_nodes)")
    do
        if [ $(get_node_is_up "$NODE_ID") = true ]; then
            log "chain height @ node-$NODE_ID = $(get_chain_height "$NODE_ID" "$TIMEOUT_SEC")"
        fi
    done
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP
unset _TIMEOUT_SEC

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        timeout) _TIMEOUT_SEC=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "${_TIMEOUT_SEC:-"0"}"
fi
