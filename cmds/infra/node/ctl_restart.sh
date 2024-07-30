#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-node-restart

    DESCRIPTION
    ----------------------------------------------------------------
    Restarts a node.

    ARGS
    ----------------------------------------------------------------
    clean       Flag indicating whether node logs & data are to be wiped. Optional.
    node        Ordinal identifier of node to be stopped.
    hash        Trusted block hash from which to restart. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    clean       true
    hash        null
    "
}

function _main()
{
    local NODE_ID=${1}
    local CLEAN=${2}
    local TRUSTED_HASH=${3}

    if [ "$(get_is_sidecar_up "$NODE_ID")" = true ]; then
        do_sidecar_stop "$NODE_ID"
        log "Sidecar $NODE_ID -> stopped"
    fi

    if [ "$(get_is_node_up "$NODE_ID")" = true ]; then
        do_node_stop "$NODE_ID"
        log "Node $NODE_ID -> stopped"
    fi

    if [ "$CLEAN" = true ]; then
        do_sidecar_clean "$NODE_ID"
        log "Sidecar $NODE_ID -> cleaned"

        do_node_clean "$NODE_ID"
        log "Node $NODE_ID -> cleaned"
    fi

    do_node_start "$NODE_ID" "$TRUSTED_HASH"
    log "Node $NODE_ID -> started"
    sleep 1.0

    do_sidecar_start "$NODE_ID"
    log "Sidecar $NODE_ID -> started"
    sleep 1.0
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _CLEAN
unset _TRUSTED_HASH
unset _HELP
unset _NODE_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        clean) _CLEAN=${VALUE} ;;
        hash) _TRUSTED_HASH=${VALUE} ;;
        help) _HELP="show" ;;
        node) _NODE_ID=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    log_break
    _main "$_NODE_ID" ${_CLEAN:-true} ${_TRUSTED_HASH:-""}
    log_break
fi
