#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-sidecar-start

    DESCRIPTION
    ----------------------------------------------------------------
    Starts a sidecar.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of node sidecar to be started.
    "
}

function _main()
{
    local NODE_ID=${1}

    if [ "$(get_is_net_up)" = true ]; then
        if [ "$(get_is_node_up "$NODE_ID")" = true ]; then
            if [ "$(get_is_sidecar_up "$NODE_ID")" = false ]; then
                do_sidecar_start "$NODE_ID"
                log "Sidecar $NODE_ID -> started"
            else
                log_warning "Node $NODE_ID -> not running, no need to start sidecar"
            fi
        else
            log_warning "Node $NODE_ID -> not running, no need to start sidecar"
        fi
    else
        log_warning "Network not running - no need to start sidecar"
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
