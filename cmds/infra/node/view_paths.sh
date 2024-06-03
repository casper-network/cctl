#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-node-view-paths

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
        for NODE_ID in $(seq 1 "$CCTL_COUNT_OF_NODES")
        do
            _display_paths "$NODE_ID"
        done
        log "------------------------------------------------------------------------------------------------------"
    else
        _display_paths "$NODE_ID"
        log "------------------------------------------------------------------------------------------------------"
    fi
}

function _display_paths()
{
    local NODE_ID=${1}
    local PATH_TO_NODE="$(get_path_to_node "$NODE_ID")"

    log "------------------------------------------------------------------------------------------------------"
    log "Paths of node-$NODE_ID assets:"
    log "------------------------------------------------------------------------------------------------------"
    log "binaries"
    log "... $PATH_TO_NODE/bin/casper-node-launcher"
    log "... $PATH_TO_NODE/bin/1_0_0/casper-node"
    log "config"
    log "... $PATH_TO_NODE/config/casper-node-launcher-state.toml"
    log "... $PATH_TO_NODE/config/1_0_0/accounts.toml"
    log "... $PATH_TO_NODE/config/1_0_0/chainspec.toml"
    log "... $PATH_TO_NODE/config/1_0_0/config.toml"
    log "keys"
    log "... $PATH_TO_NODE/keys/public_key_hex"
    log "... $PATH_TO_NODE/keys/public_key.pem"
    log "... $PATH_TO_NODE/keys/secret_key.pem"
    log "logs"
    log "... $PATH_TO_NODE/logs/node-stderr.log"
    log "... $PATH_TO_NODE/logs/node-stdout.log"
    log "... $PATH_TO_NODE/logs/sidecar-stderr.log"
    log "... $PATH_TO_NODE/logs/sidecar-stdout.log"
    log "... $PATH_TO_NODE/storage/$CCTL_NET_NAME"
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
