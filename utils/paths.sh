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
# Returns path to casper client binary.
# Globals:
#   CSPR_COMPILE_TARGET
#   CSPR_PATH_TO_CASPER_CLIENT_BINARY
#######################################
function get_path_to_binary_of_casper_client()
{
    local COMPILE_TARGET
    local PATH_TO_BINARY

    if ((${#CSPR_PATH_TO_CASPER_CLIENT_BINARY[@]})); then
        echo $CSPR_PATH_TO_CASPER_CLIENT_BINARY
    else
        COMPILE_TARGET=${CSPR_COMPILE_TARGET:-release}
        PATH_TO_BINARY="casper-client-rs/target/$COMPILE_TARGET/casper-client"
        echo $(get_path_to_working_directory_file $PATH_TO_BINARY)
    fi   
}

#######################################
# Returns path to casper node binary.
# Globals:
#   CSPR_COMPILE_TARGET
#   CSPR_PATH_TO_CASPER_NODE_BINARY.
#######################################
function get_path_to_binary_of_casper_node()
{
    local COMPILE_TARGET
    local PATH_TO_BINARY

    if ((${#CSPR_PATH_TO_CASPER_NODE_BINARY[@]})); then
        echo $CSPR_PATH_TO_CASPER_NODE_BINARY
    else
        COMPILE_TARGET=${CSPR_COMPILE_TARGET:-release}
        PATH_TO_BINARY="casper-node/target/$COMPILE_TARGET/casper-node"
        echo $(get_path_to_working_directory_file $PATH_TO_BINARY)
    fi   
}

#######################################
# Returns path to casper node launcher binary.
# Globals:
#   CSPR_COMPILE_TARGET
#   CSPR_PATH_TO_CASPER_NODE_LAUNCHER_BINARY.
#######################################
function get_path_to_binary_of_casper_node_launcher()
{
    local COMPILE_TARGET
    local PATH_TO_BINARY

    if ((${#CSPR_PATH_TO_CASPER_NODE_LAUNCHER_BINARY[@]})); then
        echo $CSPR_PATH_TO_CASPER_NODE_LAUNCHER_BINARY
    else
        COMPILE_TARGET=${CSPR_COMPILE_TARGET:-release}
        PATH_TO_BINARY="casper-node-launcher/target/$COMPILE_TARGET/casper-node-launcher"
        echo $(get_path_to_working_directory_file $PATH_TO_BINARY)
    fi   
}

#######################################
# Returns path to casper node resources folder.
# Globals:
#   CSPR_PATH_TO_CASPER_NODE_RESOURCES.
#######################################
function get_path_to_casper_node_resources()
{
    if ((${#CSPR_PATH_TO_CASPER_NODE_RESOURCES[@]})); then
        echo $CSPR_PATH_TO_CASPER_NODE_RESOURCES
    else
        echo $(get_path_to_assets)/resources
    fi
}

#######################################
# Returns path to casper node wasm folder.
# Globals:
#   CSPR_PATH_TO_CASPER_NODE_WASM.
#######################################
function get_path_to_wasm_of_casper_node()
{
    if ((${#CSPR_PATH_TO_CASPER_NODE_WASM[@]})); then
        echo $CSPR_PATH_TO_CASPER_NODE_WASM
    else

        echo $(get_path_to_assets)/bin/wasm
    fi
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
# Returns path to working directory within which cctl has been cloned.
#######################################
function get_path_to_working_directory()
{
    echo "$( cd "$( dirname "${CCTL[0]}" )" && pwd )"
}

#######################################
# Returns path to a file within cctl working directory.
#######################################
function get_path_to_working_directory_file()
{
    local FILE_SUBPATH=${1}

    echo "$(get_path_to_working_directory)"/"$FILE_SUBPATH"
}

#######################################
# Returns path to a network supervisord config file.
#######################################
function get_path_to_net_supervisord_cfg()
{
    echo "$(get_path_to_assets)"/daemon/config/supervisord.conf
}

#######################################
# Returns path to a network supervisord socket file.
#######################################
function get_path_to_net_supervisord_sock()
{
    echo /tmp/cctl-supervisord.sock
}

#######################################
# Returns path to a node's local assets.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_path_to_node()
{
    local NODE_ID=${1:-1}

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
    local NODE_ID=${1:-1}

    echo "$(get_path_to_node "$NODE_ID")"/logs
}

#######################################
# Returns path to a node's storage directory.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_path_to_node_storage()
{
    local NODE_ID=${1:-1}

    echo "$(get_path_to_node "$NODE_ID")"/storage
}

#######################################
# Returns path to a node's secret key.
# Globals:
#   CCTL_ACCOUNT_TYPE_NODE
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
