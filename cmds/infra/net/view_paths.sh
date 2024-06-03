#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-net-view-paths

    DESCRIPTION
    ----------------------------------------------------------------
    Displays paths pertinent to each running net.
    "
}

function _main()
{
    local PATH_TO_ASSETS=$(get_path_to_assets)

    echo $PATH_TO_ASSETS
    log "------------------------------------------------------------------------------------------------------"
    log "Paths of network assets:"
    log "------------------------------------------------------------------------------------------------------"
    log "binaries"
    log "... $PATH_TO_ASSETS/bin/casper-client"
    log "wasm"
    log "... $PATH_TO_ASSETS/bin/activate_bid.wasm"
    log "... $PATH_TO_ASSETS/bin/add_bid.wasm"
    log "... $PATH_TO_ASSETS/bin/delegate.wasm"
    log "... $PATH_TO_ASSETS/bin/named_purse_payment.wasm"
    log "... $PATH_TO_ASSETS/bin/transfer_to_account_u512.wasm"
    log "... $PATH_TO_ASSETS/bin/undelegate.wasm"
    log "... $PATH_TO_ASSETS/bin/withdraw_bid.wasm"
    log "daemon"
    log "... $PATH_TO_ASSETS/daemon/config/supervisord.conf"
    log "... $PATH_TO_ASSETS/daemon/logs/supervisord.log"
    log "... $PATH_TO_ASSETS/daemon/socket/supervisord.pid"
    log "faucet"
    log "... $PATH_TO_ASSETS/faucet/public_key_hex"
    log "... $PATH_TO_ASSETS/faucet/public_key.pem"
    log "... $PATH_TO_ASSETS/faucet/secret_key.pem"
    log "genesis"
    log "... $PATH_TO_ASSETS/genesis/accounts.toml"
    log "... $PATH_TO_ASSETS/genesis/chainspec.toml"
    log "nodes"
    log "... $PATH_TO_ASSETS/nodes/node-1"
    log "... $PATH_TO_ASSETS/nodes/node-2"
    log "... $PATH_TO_ASSETS/nodes/node-3"
    log "... $PATH_TO_ASSETS/nodes/node-4"
    log "... $PATH_TO_ASSETS/nodes/node-5"
    log "... $PATH_TO_ASSETS/nodes/node-6"
    log "... $PATH_TO_ASSETS/nodes/node-7"
    log "... $PATH_TO_ASSETS/nodes/node-8"
    log "... $PATH_TO_ASSETS/nodes/node-9"
    log "... $PATH_TO_ASSETS/nodes/node-10"
    log "users"
    log "... $PATH_TO_ASSETS/users/user-1"
    log "... $PATH_TO_ASSETS/users/user-2"
    log "... $PATH_TO_ASSETS/users/user-3"
    log "... $PATH_TO_ASSETS/users/user-4"
    log "... $PATH_TO_ASSETS/users/user-5"
    log "... $PATH_TO_ASSETS/users/user-6"
    log "... $PATH_TO_ASSETS/users/user-7"
    log "... $PATH_TO_ASSETS/users/user-8"
    log "... $PATH_TO_ASSETS/users/user-9"
    log "... $PATH_TO_ASSETS/users/user-10"
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
