#!/usr/bin/env bash

#######################################
# Returns path to primary assets folder.
# Globals:
#   CCTL - path to cctl home directory.
#######################################
function get_path_to_assets()
{
    echo "${CCTL_ASSETS:-$CCTL/assets}"
}

#######################################
# Returns path to a network's binary folder.
#######################################
function get_path_to_assets_bin()
{
    echo "$(get_path_to_assets)"/bin
}

#######################################
# Returns path to a binary file.
# Arguments:
#   Binary file name.
#######################################
function get_path_to_binary()
{
    local FILENAME=${1}    

    echo "$(get_path_to_assets)"/bin/"$FILENAME"
}

#######################################
# Returns path to client binary.
#######################################
function get_path_to_client()
{
    get_path_to_binary "casper-client"
}

#######################################
# Returns path to a network faucet.
#######################################
function get_path_to_faucet()
{
    echo "$(get_path_to_assets)"/faucet
}

#######################################
# Returns path to directory containing transactions dispatched into network.
#######################################
function get_path_to_transactions()
{
    echo "$(get_path_to_assets)"/transactions
}

#######################################
# Returns path to a wasm file.
# Arguments:
#   Wasm file name.
#######################################
function get_path_to_wasm()
{
    local FILENAME=${1}    

    echo "$(get_path_to_assets)"/bin/wasm/"$FILENAME"
}

#######################################
# Returns path to a network's supervisord config file.
#######################################
function get_path_net_supervisord_cfg()
{
    echo "$(get_path_to_assets)"/daemon/config/supervisord.conf
}

#######################################
# Returns path to a network's supervisord socket file.
#######################################
function get_path_net_supervisord_sock()
{
    echo /tmp/cctl-supervisord.sock
}

#######################################
# Returns path to a node's assets.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_path_to_node()
{
    local NODE_ID=${1} 

    echo "$(get_path_to_assets)"/nodes/node-"$NODE_ID"
}

#######################################
# Returns path to a node's binary folder.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_path_to_node_bin()
{
    local NODE_ID=${1:-1}

    echo "$(get_path_to_node "$NODE_ID")"/bin
}

#######################################
# Returns path to a node's config folder.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_path_to_node_config()
{
    local NODE_ID=${1:-1}
    
    echo "$(get_path_to_node "$NODE_ID")"/config
}

#######################################
# Returns path to a node's active config file.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_path_to_node_config_file()
{
    local NODE_ID=${1:-1}

    echo "$(get_path_to_node "$NODE_ID")/config/1_0_0/config.toml"
}

#######################################
# Returns path to a node's logs directory.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_path_to_node_logs()
{
    echo "$(get_path_to_node "$1")"/logs
}

#######################################
# Returns path to a node's storage directory.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_path_to_node_storage()
{
    echo "$(get_path_to_node "$1")"/storage
}

#######################################
# Returns path to a node's secret key.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_path_to_node_secret_key()
{
    local NODE_ID=${1} 

    get_path_to_secret_key "$CCTL_ACCOUNT_TYPE_NODE" "$NODE_ID"
}

#######################################
# Returns path to primary resources folder.
# Globals:
#   CCTL - path to cctl home directory.
#######################################
function get_path_to_resources()
{
    echo "$CCTL/resources"
}

#######################################
# Returns path to a secret key.
# Globals:
#   CCTL_ACCOUNT_TYPE_FAUCET - faucet account type.
#   CCTL_ACCOUNT_TYPE_NODE - node account type.
#   CCTL_ACCOUNT_TYPE_USER - user account type.
# Arguments:
#   Account type (node | user | faucet).
#   Account ordinal identifier (optional).
#######################################
function get_path_to_secret_key()
{
    local ACCOUNT_TYPE=${1}
    local ACCOUNT_IDX=${2}

    if [ "$ACCOUNT_TYPE" = "$CCTL_ACCOUNT_TYPE_FAUCET" ]; then
        echo "$(get_path_to_faucet)"/secret_key.pem
    elif [ "$ACCOUNT_TYPE" = "$CCTL_ACCOUNT_TYPE_NODE" ]; then
        echo "$(get_path_to_node "$ACCOUNT_IDX")"/keys/secret_key.pem
    elif [ "$ACCOUNT_TYPE" = "$CCTL_ACCOUNT_TYPE_USER" ]; then
        echo "$(get_path_to_user "$ACCOUNT_IDX")"/secret_key.pem
    fi
}

#######################################
# Returns path to a user's assets.
# Arguments:
#   User ordinal identifier.
#######################################
function get_path_to_user()
{
    local USER_ID=${1}

    echo "$(get_path_to_assets)"/users/user-"$USER_ID"
}
