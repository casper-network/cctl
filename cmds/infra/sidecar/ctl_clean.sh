#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-sidecar-clean

    DESCRIPTION
    ----------------------------------------------------------------
    Cleans sidecar logs & data.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of node sidecar to be cleaned.
    "
}

function _main()
{
    local NODE_ID=${1}

    if [ "$(get_is_sidecar_up "$NODE_ID")" = true ]; then
        log "Sidecar $NODE_ID -> currently running ... please stop prior to cleaning"
    else
        do_sidecar_clean_logs "$NODE_ID"
        log "Sidecar $NODE_ID -> cleaned"
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
