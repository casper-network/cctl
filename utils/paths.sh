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
# Returns path to node config templates folder.
# Globals:
#   CSPR_PATH_TO_RESOURCES.
#######################################
function get_path_to_config_templates_of_node()
{
    if ((${#CSPR_PATH_TO_RESOURCES[@]})); then
        echo $CSPR_PATH_TO_RESOURCES
    else
        echo $(get_path_to_working_directory)/casper-node/resources
    fi
}

#######################################
# Returns path to sidecar resources folder.
# Globals:
#   CSPR_PATH_TO_RESOURCES.
#######################################
function get_path_to_config_templates_of_sidecar()
{
    if ((${#CSPR_PATH_TO_RESOURCES[@]})); then
        echo $CSPR_PATH_TO_RESOURCES
    else
        echo $(get_path_to_working_directory)/casper-sidecar/resources
    fi
}

#######################################
# Returns path to compiled client binary.
# Globals:
#   CSPR_COMPILE_TARGET
#   CSPR_PATH_TO_BIN
#######################################
function get_path_to_compiled_client()
{
    local COMPILE_TARGET
    local PATH_TO_BINARY

    if ((${#CSPR_PATH_TO_BIN[@]})); then
        echo $CSPR_PATH_TO_BIN/casper-client
    else
        COMPILE_TARGET=${CSPR_COMPILE_TARGET:-release}
        PATH_TO_BINARY="casper-client-rs/target/$COMPILE_TARGET/casper-client"
        echo $(get_path_to_working_directory_file $PATH_TO_BINARY)
    fi
}

#######################################
# Returns path to compiled node binary.
# Globals:
#   CSPR_COMPILE_TARGET
#   CSPR_PATH_TO_BIN.
#######################################
function get_path_to_compiled_node()
{
    local COMPILE_TARGET
    local PATH_TO_BINARY

    if ((${#CSPR_PATH_TO_BIN[@]})); then
        echo $CSPR_PATH_TO_BIN/casper-node
    else
        COMPILE_TARGET=${CSPR_COMPILE_TARGET:-release}
        PATH_TO_BINARY="casper-node/target/$COMPILE_TARGET/casper-node"
        echo $(get_path_to_working_directory_file $PATH_TO_BINARY)
    fi
}

#######################################
# Returns path to compiled node launcher binary.
# Globals:
#   CSPR_COMPILE_TARGET
#   CSPR_PATH_TO_BIN.
#######################################
function get_path_to_compiled_node_launcher()
{
    local COMPILE_TARGET
    local RELATIVE_PATH_TO_BINARY

    if ((${#CSPR_PATH_TO_BIN[@]})); then
        echo $CSPR_PATH_TO_BIN/casper-node-launcher
    else
        COMPILE_TARGET=${CSPR_COMPILE_TARGET:-release}
        RELATIVE_PATH_TO_BINARY="casper-node-launcher/target/$COMPILE_TARGET/casper-node-launcher"
        echo $(get_path_to_working_directory_file $RELATIVE_PATH_TO_BINARY)
    fi
}

#######################################
# Returns path to compiled sidecar binary.
# Globals:
#   CSPR_COMPILE_TARGET
#   CSPR_PATH_TO_BIN.
#######################################
function get_path_to_compiled_sidecar()
{
    local COMPILE_TARGET
    local PATH_TO_BINARY

    if ((${#CSPR_PATH_TO_BIN[@]})); then
        echo $CSPR_PATH_TO_BIN/casper-sidecar
    else
        COMPILE_TARGET=${CSPR_COMPILE_TARGET:-release}
        PATH_TO_BINARY="casper-sidecar/target/$COMPILE_TARGET/casper-sidecar"
        echo $(get_path_to_working_directory_file $PATH_TO_BINARY)
    fi
}

#######################################
# Returns path to compiled wasm folder.
# Globals:
#   CSPR_COMPILE_TARGET
#   CSPR_PATH_TO_BIN.
#######################################
function get_path_to_compiled_wasm()
{
    local COMPILE_TARGET
    local RELATIVE_PATH_TO_WASM

    if ((${#CSPR_PATH_TO_BIN[@]})); then
        echo $CSPR_PATH_TO_BIN
    else
        COMPILE_TARGET=${CSPR_COMPILE_TARGET:-release}
        RELATIVE_PATH_TO_WASM="casper-node/target/wasm32-unknown-unknown/$COMPILE_TARGET"
        echo $(get_path_to_working_directory_file $RELATIVE_PATH_TO_WASM)
    fi
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
# Returns path to client binary.
#######################################
function get_path_to_node_client()
{
    echo "$(get_path_to_assets)"/bin/casper-client
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
        echo "$(get_path_to_assets)"/faucet/secret_key.pem
    elif [ "$ACCOUNT_TYPE" = "$CCTL_ACCOUNT_TYPE_NODE" ]; then
        echo "$(get_path_to_node "$ACCOUNT_IDX")"/keys/secret_key.pem
    elif [ "$ACCOUNT_TYPE" = "$CCTL_ACCOUNT_TYPE_USER" ]; then
        echo "$(get_path_to_user "$ACCOUNT_IDX")"/secret_key.pem
    fi
}

#######################################
# Returns path to a network supervisord config file.
#######################################
function get_path_to_supervisord_cfg()
{
    echo "$(get_path_to_assets)"/daemon/config/supervisord.conf
}

#######################################
# Returns path to a network supervisord socket file.
#######################################
function get_path_to_supervisord_sock()
{
    echo /tmp/cctl-supervisord.sock
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
