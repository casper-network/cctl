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
        log "sidecar $NODE_ID :: currently running ... please stop prior to cleaning."
    else
        log "sidecar $NODE_ID :: cleaning ... please wait"
        _clean_node "$NODE_ID"
        log "sidecar $NODE_ID :: cleaned"
    fi
}

function _clean_node()
{
    local NODE_ID=${1}

    local PATH_TO_LOGS=$(get_path_to_sidecar_logs "$NODE_ID")

    log "sidecar $NODE_ID :: cleaning logs"
    rm "$PATH_TO_LOGS"/sidecar-*.log > /dev/null 2>&1
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
    _main "$_NODE_ID"
fi
