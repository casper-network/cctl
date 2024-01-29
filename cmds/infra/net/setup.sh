#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-net-setup

    DESCRIPTION
    ----------------------------------------------------------------
    Sets up network assets prior to spin up.

    ARGS
    ----------------------------------------------------------------
    accounts    Type of genesis accounts, i.e. dynamic | static. Optional.
    chainspec   Path to custom genesis chainspec.toml. Optional.
    config      Path to custom genesis chainspec.toml. Optional.
    delay       Delay in seconds prior to genesis window expiration. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    accounts    static
    chainspec   $(get_path_to_casper_node_resources)/resources/local/chainspec.toml.in
    config      $(get_path_to_casper_node_resources)/resources/local/config.toml
    delay       30 seconds

    NOTES
    ----------------------------------------------------------------
    Initially the network consists of 5 active nodes plus 5 standby nodes.
    This typology permits node rotation testing scenarios.
    "
}

function _main()
{
    local GENESIS_ACCOUNTS_TYPE=${1}
    local GENESIS_DELAY=${2}
    local PATH_TO_CHAINSPEC=${3}
    local PATH_TO_NODE_CONFIG_TEMPLATE=${4}

    echo $3
    echo $4

    # local NODE_COUNT=10
    # local NODE_COUNT_AT_GENESIS=5
    # local USER_COUNT=10

    # log "network setup begins ... please wait"

    # log "... tearing down existing"
    # _teardown

    # log "... setting assets directory"
    # _setup_fs "$NODE_COUNT" "$USER_COUNT"

    # log "... setting binaries"
    # _setup_binaries "$NODE_COUNT"

    # log "... setting wasm payloads"
    # _setup_wasm

    # log "... setting cryptographic keys"
    # _setup_keys "$GENESIS_ACCOUNTS_TYPE" "$NODE_COUNT" "$USER_COUNT"

    # log "... setting supervisor config"
    # _setup_supervisor "$NODE_COUNT"

    # log "... setting genesis chainspec.toml"
    # _setup_genesis_chainspec "$GENESIS_DELAY" "$NODE_COUNT" "$PATH_TO_CHAINSPEC"

    # log "... setting genesis accounts.toml"
    # _setup_genesis_accounts "$GENESIS_ACCOUNTS_TYPE" "$NODE_COUNT" "$NODE_COUNT_AT_GENESIS" "$USER_COUNT"

    # log "... setting node configs"
    # _setup_node_configs "$NODE_COUNT" "$PATH_TO_NODE_CONFIG_TEMPLATE"

    # log "network setup complete"
}

function _teardown()
{
    _teardown_net
    _teardown_assets
}

function _teardown_net()
{
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_net_supervisord_cfg)
    local PATH_TO_SUPERVISOR_SOCKET=$(get_path_to_net_supervisord_sock)

    if [ -e "$PATH_TO_SUPERVISOR_SOCKET" ]; then
        supervisorctl -c "$PATH_TO_SUPERVISOR_CONFIG" shutdown > /dev/null 2>&1 || true
        sleep 2.0
    fi
}

function _teardown_assets()
{
    local _PATH_TO_ASSETS=$(get_path_to_assets)

    if [ -d "$_PATH_TO_ASSETS" ]; then
        rm -rf "$_PATH_TO_ASSETS"
    fi
}

function _setup_node_configs()
{
    local NODE_COUNT=${1}
    local PATH_TO_NODE_CONFIG_TEMPLATE=${2}

    local NODE_ID
    local PATH_TO_ASSETS=$(get_path_to_assets)

    for NODE_ID in $(seq 1 "$NODE_COUNT")
    do
        _setup_node_config $NODE_ID $PATH_TO_NODE_CONFIG_TEMPLATE
    done
}

function _setup_node_config()
{
    local NODE_ID=${1}
    local PATH_TO_NODE_CONFIG_TEMPLATE=${2}

    local PATH_TO_ASSETS=$(get_path_to_assets)
    local PATH_TO_NODE_CONFIG
    local SCRIPT

    PATH_TO_NODE_CONFIG_DIR="$(get_path_to_node "$NODE_ID")/config/1_0_0"
    PATH_TO_NODE_CONFIG="$PATH_TO_NODE_CONFIG_DIR/config.toml"

    cp "$PATH_TO_ASSETS/genesis/accounts.toml" "$PATH_TO_NODE_CONFIG_DIR"
    cp "$PATH_TO_ASSETS/genesis/chainspec.toml" "$PATH_TO_NODE_CONFIG_DIR"

    cp "$PATH_TO_NODE_CONFIG_TEMPLATE" "$PATH_TO_NODE_CONFIG"
    SCRIPT=(
        "import toml;"
        "cfg=toml.load('$PATH_TO_NODE_CONFIG');"
        "cfg['consensus']['secret_key_path']='../../keys/secret_key.pem';"
        "cfg['logging']['format']='json';"
        "cfg['network']['bind_address']='$(get_network_bind_address "$NODE_ID")';"
        "cfg['network']['known_addresses']=[$(get_network_known_addresses "$NODE_ID")];"
        "cfg['storage']['path']='../../storage';"
        "cfg['rest_server']['address']='0.0.0.0:$(get_node_port_rest "$NODE_ID")';"
        "cfg['rpc_server']['address']='0.0.0.0:$(get_node_port_rpc "$NODE_ID")';"
        "cfg['event_stream_server']['address']='0.0.0.0:$(get_node_port_sse "$NODE_ID")';"
        "cfg['diagnostics_port']['enabled']=False;"
        "cfg['speculative_exec_server']['address']='0.0.0.0:$(get_node_port_speculative_exec "$NODE_ID")';"
        "toml.dump(cfg, open('$PATH_TO_NODE_CONFIG', 'w'));"
    )
    python3 -c "${SCRIPT[*]}"
}

function _get_node_pos_stake_weight()
{
    local NODE_COUNT_AT_GENESIS=${1}
    local NODE_ID=${2}
    local POS_WEIGHT

    if [ "$NODE_ID" -le "$NODE_COUNT_AT_GENESIS" ]; then
        POS_WEIGHT=$(get_node_staking_weight "$NODE_ID")
    else
        POS_WEIGHT="0"
    fi
    if [ "x$POS_WEIGHT" = 'x' ]; then
        POS_WEIGHT="0"
    fi

    echo $POS_WEIGHT
}

function _setup_binaries()
{
    local NODE_COUNT=${1}

    local NODE_ID
    local PATH_TO_BINARY_OF_CASPER_CLIENT=$(get_path_to_binary_of_casper_client)
    local PATH_TO_BINARY_OF_CASPER_NODE=$(get_path_to_binary_of_casper_node)
    local PATH_TO_BINARY_OF_CASPER_NODE_LAUNCHER=$(get_path_to_binary_of_casper_node_launcher)
    local PATH_TO_NODE_BIN
    local PATH_TO_WASM_OF_CASPER_NODE=$(get_path_to_wasm_of_casper_node)
    
    cp "$(get_path_to_binary_of_casper_client)" "$(get_path_to_assets)"/bin
    for NODE_ID in $(seq 1 "$NODE_COUNT")
    do
        PATH_TO_NODE_BIN="$(get_path_to_node_bin "$NODE_ID")"
        cp "$(get_path_to_binary_of_casper_node)" "$PATH_TO_NODE_BIN/1_0_0"
        cp "$(get_path_to_binary_of_casper_node_launcher)" "$PATH_TO_NODE_BIN"
    done
}

function _setup_supervisor()
{
    local NODE_COUNT=${1}

    local PATH_TO_ASSETS=$(get_path_to_assets)
    local PATH_TO_NODE_BIN
    local PATH_TO_NODE_CONFIG
    local PATH_TO_NODE_LOGS
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_net_supervisord_cfg)
    local PATH_TO_SUPERVISOR_SOCK=$(get_path_to_net_supervisord_sock)

    touch "$PATH_TO_SUPERVISOR_CONFIG"

# Set supervisord.conf header.
cat >> "$PATH_TO_SUPERVISOR_CONFIG" <<- EOM
[unix_http_server]
file=$PATH_TO_SUPERVISOR_SOCK ;

[supervisord]
logfile=$PATH_TO_ASSETS/daemon/logs/supervisord.log ;
logfile_maxbytes=200MB ;
logfile_backups=10 ;
loglevel=info ;
pidfile=$PATH_TO_ASSETS/daemon/socket/supervisord.pid ;

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///$PATH_TO_SUPERVISOR_SOCK ;
EOM

# Set supervisord.conf app sections.
for IDX in $(seq 1 "$NODE_COUNT")
do
    PATH_TO_NODE_BIN=$(get_path_to_node_bin "$IDX")
    PATH_TO_NODE_CONFIG=$(get_path_to_node_config "$IDX")
    PATH_TO_NODE_LOGS=$(get_path_to_node_logs "$IDX")

    cat >> "$PATH_TO_SUPERVISOR_CONFIG" <<- EOM

[program:cctl-node-$IDX]
autostart=false
autorestart=false
command=$PATH_TO_NODE_BIN/casper-node-launcher
environment=CASPER_BIN_DIR="$PATH_TO_NODE_BIN",CASPER_CONFIG_DIR="$PATH_TO_NODE_CONFIG"
numprocs=1
numprocs_start=0
startsecs=0
stopsignal=TERM
stopwaitsecs=5
stopasgroup=true
stderr_logfile=$PATH_TO_NODE_LOGS/stderr.log ;
stderr_logfile_backups=5 ;
stderr_logfile_maxbytes=500MB ;
stdout_logfile=$PATH_TO_NODE_LOGS/stdout.log ;
stdout_logfile_backups=5 ;
stdout_logfile_maxbytes=500MB ;
EOM
done

# Set supervisord.conf group sections.
cat >> "$PATH_TO_SUPERVISOR_CONFIG" <<- EOM

[group:$CCTL_PROCESS_GROUP_1]
programs=$(get_process_group_members "$CCTL_PROCESS_GROUP_1")

[group:$CCTL_PROCESS_GROUP_2]
programs=$(get_process_group_members "$CCTL_PROCESS_GROUP_2")

[group:$CCTL_PROCESS_GROUP_3]
programs=$(get_process_group_members "$CCTL_PROCESS_GROUP_3")

EOM

}

function _setup_fs()
{
    local NODE_COUNT=${1}
    local USER_COUNT=${2}

    local PATH_TO_ASSETS=$(get_path_to_assets)
    local PATH_TO_NODE
    local IDX

    mkdir -p "$PATH_TO_ASSETS"
    mkdir "$PATH_TO_ASSETS/bin"
    mkdir "$PATH_TO_ASSETS/bin/wasm"
    mkdir "$PATH_TO_ASSETS/daemon"
    mkdir "$PATH_TO_ASSETS/daemon/config"
    mkdir "$PATH_TO_ASSETS/daemon/logs"
    mkdir "$PATH_TO_ASSETS/daemon/socket"
    mkdir "$PATH_TO_ASSETS/faucet"
    mkdir "$PATH_TO_ASSETS/genesis"
    mkdir "$PATH_TO_ASSETS/nodes"
    mkdir "$PATH_TO_ASSETS/users"

    for IDX in $(seq 1 "$NODE_COUNT")
    do
        PATH_TO_NODE="$PATH_TO_ASSETS"/nodes/node-"$IDX"
        mkdir "$PATH_TO_NODE"
        mkdir "$PATH_TO_NODE/bin"
        mkdir "$PATH_TO_NODE/bin/1_0_0"
        mkdir "$PATH_TO_NODE/config"
        mkdir "$PATH_TO_NODE/config/1_0_0"
        mkdir "$PATH_TO_NODE/keys"
        mkdir "$PATH_TO_NODE/logs"
        mkdir "$PATH_TO_NODE/storage"
    done

    for IDX in $(seq 1 "$USER_COUNT")
    do
        mkdir "$PATH_TO_ASSETS"/users/user-"$IDX"
    done
}

function _setup_genesis_accounts()
{
    local GENESIS_ACCOUNTS_TYPE=${1}
    local NODE_COUNT=${2}
    local NODE_COUNT_AT_GENESIS=${3}
    local USER_COUNT=${4}

    if [ "$GENESIS_ACCOUNTS_TYPE" = "dynamic" ]; then
        _setup_genesis_accounts_dynamic $NODE_COUNT $NODE_COUNT_AT_GENESIS $USER_COUNT
    else
        _setup_genesis_accounts_static
    fi
}

function _setup_genesis_accounts_dynamic()
{
    local NODE_COUNT=${1}
    local NODE_COUNT_AT_GENESIS=${2}
    local USER_COUNT=${3}

    local IDX
    local PATH_TO_ACCOUNTS
    local PATH_TO_ASSETS="$(get_path_to_assets)"
    local PATH_TO_ACCOUNTS="$PATH_TO_ASSETS/genesis/accounts.toml"

    # Set accounts.toml.
    touch "$PATH_TO_ACCOUNTS"

    # Set faucet account entry.
    cat >> "$PATH_TO_ACCOUNTS" <<- EOM
# FAUCET.
[[accounts]]
public_key = "$(cat "$PATH_TO_ASSETS/faucet/public_key_hex")"
balance = "$CCTL_INITIAL_BALANCE_FAUCET"
EOM

    # Set validator account entries.
    for IDX in $(seq 1 "$NODE_COUNT")
    do
        cat >> "$PATH_TO_ACCOUNTS" <<- EOM

# VALIDATOR $IDX.
[[accounts]]
public_key = "$(cat "$PATH_TO_ASSETS/nodes/node-$IDX/keys/public_key_hex")"
balance = "$CCTL_INITIAL_BALANCE_VALIDATOR"
EOM
        if [ "$IDX" -le "$NODE_COUNT_AT_GENESIS" ]; then
        cat >> "$PATH_TO_ACCOUNTS" <<- EOM

[accounts.validator]
bonded_amount = "$(_get_node_pos_stake_weight "$NODE_COUNT_AT_GENESIS" "$IDX")"
delegation_rate = $IDX
EOM
        fi
    done

    # Set user account entries.
    for IDX in $(seq 1 "$USER_COUNT")
    do
        if [ "$IDX" -le "$NODE_COUNT_AT_GENESIS" ]; then
        cat >> "$PATH_TO_ACCOUNTS" <<- EOM

# USER $IDX.
[[delegators]]
validator_public_key = "$(cat "$PATH_TO_ASSETS/nodes/node-$IDX/keys/public_key_hex")"
delegator_public_key = "$(cat "$PATH_TO_ASSETS/users/user-$IDX/public_key_hex")"
balance = "$CCTL_INITIAL_BALANCE_USER"
delegated_amount = "$((CCTL_INITIAL_DELEGATION_AMOUNT + IDX))"
EOM
        else
        cat >> "$PATH_TO_ACCOUNTS" <<- EOM

# USER $IDX.
[[accounts]]
public_key = "$(cat "$PATH_TO_ASSETS/users/user-$IDX/public_key_hex")"
balance = "$CCTL_INITIAL_BALANCE_USER"
EOM
        fi
    done
}

function _setup_genesis_accounts_static()
{
    cp \
        "$(get_path_to_resources)"/static/accounts/accounts.toml \
        "$(get_path_to_assets)"/genesis/accounts.toml
}

function _setup_genesis_chainspec()
{
    local GENESIS_DELAY=${1}
    local NODE_COUNT=${2}
    local PATH_TO_CHAINSPEC_TEMPLATE=${3}

    local ACTIVATION_POINT=$(get_genesis_timestamp "$GENESIS_DELAY")
    local PROTOCOL_VERSION=1.0.0

    local PATH_TO_CHAINSPEC
    local SCRIPT

    PATH_TO_CHAINSPEC="$(get_path_to_assets)/genesis/chainspec.toml"
    cp "$PATH_TO_CHAINSPEC_TEMPLATE" "$PATH_TO_CHAINSPEC"

    SCRIPT=(
        "import toml;"
        "cfg=toml.load('$PATH_TO_CHAINSPEC');"
        "cfg['core']['validator_slots']=$NODE_COUNT;"
        "cfg['protocol']['activation_point']='$ACTIVATION_POINT';"
        "cfg['protocol']['version']='$PROTOCOL_VERSION';"
        "cfg['network']['name']='$CCTL_NET_NAME';"
        "toml.dump(cfg, open('$PATH_TO_CHAINSPEC', 'w'));"
    )
    python3 -c "${SCRIPT[*]}"
}

function _setup_keys()
{
    local GENESIS_ACCOUNTS_TYPE=${1}
    local NODE_COUNT=${2}
    local USER_COUNT=${3}

    if [ "$GENESIS_ACCOUNTS_TYPE" = "dynamic" ]; then
        _setup_keys_dynamic $NODE_COUNT $USER_COUNT
    else
        _setup_keys_static $NODE_COUNT $USER_COUNT
    fi
}

function _setup_keys_dynamic()
{
    local NODE_COUNT=${1}
    local USER_COUNT=${2}

    local PATH_TO_ASSETS=$(get_path_to_assets)
    local IDX
    local CASPER_CLIENT="$(get_path_to_client)"

    "$CASPER_CLIENT" \
        keygen -f "$PATH_TO_ASSETS/faucet" > /dev/null 2>&1

    for IDX in $(seq 1 "$NODE_COUNT")
    do
        "$CASPER_CLIENT" \
            keygen -f "$PATH_TO_ASSETS/nodes/node-$IDX/keys" > /dev/null 2>&1
    done

    for IDX in $(seq 1 "$USER_COUNT")
    do
        "$CASPER_CLIENT" \
            keygen -f "$PATH_TO_ASSETS/users/user-$IDX" > /dev/null 2>&1
    done
}

function _setup_keys_static()
{
    local IDX

    cp \
        "$(get_path_to_resources)"/static/accounts/faucet/* \
        "$(get_path_to_assets)"/faucet

    for IDX in $(seq 1 "$NODE_COUNT")
    do
        cp \
            "$(get_path_to_resources)"/static/accounts/nodes/node-$IDX/* \
            "$(get_path_to_assets)"/nodes/node-$IDX/keys
    done

    for IDX in $(seq 1 "$USER_COUNT")
    do
        cp \
            "$(get_path_to_resources)"/static/accounts/users/user-$IDX/* \
            "$(get_path_to_assets)"/users/user-$IDX
    done
}

function _setup_wasm()
{
    local PATH_TO_ASSETS=$(get_path_to_assets)
    local PATH_TO_WASM_OF_CASPER_NODE=$(get_path_to_wasm_of_casper_node)

    echo $PATH_TO_WASM_OF_CASPER_NODE

    for CONTRACT in "${CCTL_SMART_CONTRACTS[@]}"
    do
        if [ -f "$PATH_TO_WASM_OF_CASPER_NODE/$CONTRACT" ]; then
            cp "$PATH_TO_WASM_OF_CASPER_NODE/$CONTRACT" "$PATH_TO_ASSETS"/bin
        fi
    done
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _GENESIS_ACCOUNTS_TYPE
unset _GENESIS_DELAY
unset _HELP
unset _PATH_TO_CHAINSPEC

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        accounts) _GENESIS_ACCOUNTS_TYPE=${VALUE} ;;
        delay) _GENESIS_DELAY=${VALUE} ;;
        help) _HELP="show" ;;
        chainspec) _PATH_TO_CHAINSPEC=${VALUE} ;;
        config) _PATH_TO_CONFIG_TOML=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    # echo $(get_path_to_casper_node_resources)

    _main \
        "${_GENESIS_ACCOUNTS_TYPE:-"static"}" \
        "${_GENESIS_DELAY:-30}" \
        "${_PATH_TO_CHAINSPEC:-"$(get_path_to_casper_node_resources)/resources/local/chainspec.toml.in"}" \
        "${_PATH_TO_CONFIG_TOML:-"$(get_path_to_casper_node_resources)/resources/local/config.toml"}"
fi
