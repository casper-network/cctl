#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-node-clean

    DESCRIPTION
    ----------------------------------------------------------------
    Cleans node logs & data.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of node to be cleaned.
    "
}

function _main()
{
    local NODE_ID=${1}

    if [ "$(get_is_node_up "$NODE_ID")" = true ]; then
        log "Node $NODE_ID -> currently running ... please stop prior to cleaning"
    else
        do_node_clean_logs "$NODE_ID"
        log "Node $NODE_ID -> logs cleaned"

        do_node_clean_storage "$NODE_ID"
        log "Node $NODE_ID -> storage cleaned"
    fi
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
    log_break
    _main "$_NODE_ID"
    log_break
fi
