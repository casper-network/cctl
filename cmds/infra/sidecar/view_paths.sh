#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-sidecar-view-paths

    DESCRIPTION
    ----------------------------------------------------------------
    Displays paths pertinent to each running node.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of a node. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    node        all
    "
}

function _main()
{
    local NODE_ID=${1}

    if [ "$NODE_ID" = "all" ]; then
        log "------------------------------------------------------------------------------------------------------"
        log "SIDECAR PATHS"
        log "------------------------------------------------------------------------------------------------------"
        for NODE_ID in $(seq 1 "$CCTL_COUNT_OF_NODES")
        do
            _display_paths "$NODE_ID"
            log "------------------------------------------------------------------------------------------------------"
        done
    else
        _display_paths "$NODE_ID"
        log "------------------------------------------------------------------------------------------------------"
    fi
}

function _display_paths()
{
    local NODE_ID=${1}
    local PATH_TO_SIDECAR="$(get_path_to_sidecar "$NODE_ID")"

    log "SIDECAR-$NODE_ID"
    log "    binaries"
    log "        $PATH_TO_SIDECAR/bin/casper-sidecar"
    log "    config"
    log "        $PATH_TO_SIDECAR/config/sidecar.toml"
    log "    logs"
    log "        $PATH_TO_SIDECAR/logs/sidecar-stderr.log"
    log "        $PATH_TO_SIDECAR/logs/sidecar-stdout.log"
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
    _main "${_NODE_ID:-"all"}"
fi
