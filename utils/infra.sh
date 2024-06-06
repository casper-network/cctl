#!/usr/bin/env bash

#######################################
# Cleans a node.
# Arguments:
#   Node ordinal identifier.
#######################################
function do_node_clean()
{
    local NODE_ID=${1}

    do_node_clean_logs "$NODE_ID"
    do_node_clean_storage "$NODE_ID"
}

#######################################
# Cleans a node's logs.
# Arguments:
#   Node ordinal identifier.
#######################################
function do_node_clean_logs()
{
    local NODE_ID=${1}

    local PATH_TO_LOGS=$(get_path_to_node_logs "$NODE_ID")

    rm "$PATH_TO_LOGS"/node-*.log > /dev/null 2>&1
}

#######################################
# Cleans a node's storage.
# Arguments:
#   Node ordinal identifier.
# Globals:
#   CCTL_NET_NAME
#######################################
function do_node_clean_storage()
{
    local NODE_ID=${1}

    local PATH_TO_STORAGE=$(get_path_to_node_storage "$NODE_ID")

    rm -rf "$PATH_TO_STORAGE"/"$CCTL_NET_NAME" > /dev/null 2>&1
}

#######################################
# Starts a node.
# Arguments:
#   Node ordinal identifier.
#######################################
function do_node_start()
{
    local NODE_ID=${1}

    local PROCESS_NAME=$(get_process_name_of_node_in_group "$NODE_ID")
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_supervisord_cfg)

    supervisorctl -c "$PATH_TO_SUPERVISOR_CONFIG" start "$PROCESS_NAME" > /dev/null 2>&1
    sleep 1.0
}

#######################################
# Stops a node.
# Arguments:
#   Node ordinal identifier.
#######################################
function do_node_stop()
{
    local NODE_ID=${1}

    local PROCESS_NAME=$(get_process_name_of_node_in_group "$NODE_ID")
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_supervisord_cfg)

    supervisorctl -c "$PATH_TO_SUPERVISOR_CONFIG" stop "$PROCESS_NAME" > /dev/null 2>&1
    sleep 1.0
}

#######################################
# Cleans a sidecar.
# Arguments:
#   Node ordinal identifier.
#######################################
function do_sidecar_clean()
{
    local NODE_ID=${1}

    do_sidecar_clean_logs "$NODE_ID"
}

#######################################
# Cleans a sidecar's logs.
# Arguments:
#   Node ordinal identifier.
#######################################
function do_sidecar_clean_logs()
{
    local NODE_ID=${1}

    local PATH_TO_LOGS=$(get_path_to_sidecar "$NODE_ID")/logs

    rm "$PATH_TO_LOGS"/sidecar-*.log > /dev/null 2>&1
}

#######################################
# Starts a sidecar.
# Arguments:
#   Node ordinal identifier.
#######################################
function do_sidecar_start()
{
    local NODE_ID=${1}

    local PROCESS_NAME=$(get_process_name_of_sidecar_in_group "$NODE_ID")
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_supervisord_cfg)

    supervisorctl -c "$PATH_TO_SUPERVISOR_CONFIG" start "$PROCESS_NAME" > /dev/null 2>&1
    sleep 1.0
}

#######################################
# Stops a sidecar.
# Arguments:
#   Node ordinal identifier.
#######################################
function do_sidecar_stop()
{
    local NODE_ID=${1}

    local PROCESS_NAME=$(get_process_name_of_sidecar_in_group "$NODE_ID")
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_supervisord_cfg)

    supervisorctl -c "$PATH_TO_SUPERVISOR_CONFIG" stop "$PROCESS_NAME" > /dev/null 2>&1
    sleep 1.0
}

#######################################
# Returns address to a node's binary server.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_address_of_node_binary_server()
{
    local NODE_ID=${1}

    echo "http://localhost:$(get_port "$CCTL_BASE_PORT_NODE_BINARY" "$NODE_ID")"
}

#######################################
# Returns address to a node's network bind server.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_address_of_node_net_bind()
{
    local NODE_ID=${1}

    echo "0.0.0.0:$(get_port "$CCTL_BASE_PORT_NODE_NETWORK" "$NODE_ID")"
}

#######################################
# Returns address to a node's rest server.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_address_of_node_rest_server()
{
    local NODE_ID=${1}
    local PORT=$(get_port "$CCTL_BASE_PORT_NODE_REST" "$NODE_ID")

    echo "http://localhost:$PORT"
}

#######################################
# Returns address to a sidecar's main server.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_address_of_sidecar_main_server()
{
    local NODE_ID=${1}

    echo "http://localhost:$(get_port "$CCTL_BASE_PORT_SIDECAR_MAIN" "$NODE_ID")"
}

#######################################
# Returns address to a sidecar's main server for use with cURL.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_address_of_sidecar_main_server_for_curl()
{
    local NODE_ID=${1}

    echo "$(get_address_of_sidecar_main_server "$NODE_ID")/rpc"
}

#######################################
# Returns address to a sidecar's sse server.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_address_of_sidecar_sse_server()
{
    local NODE_ID=${1}

    echo "http://localhost:$(get_port "$CCTL_BASE_PORT_NODE_SSE" "$NODE_ID")"
}

#######################################
# Returns a bootstrap known address - i.e. those of bootstrap nodes.
# Globals:
#   CCTL_BASE_PORT_NODE_NETWORK - base network port number.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_bootstrap_known_address()
{
    local NODE_ID=${1}
    local NODE_PORT=$((CCTL_BASE_PORT_NODE_NETWORK + 100 + NODE_ID))

    echo "'127.0.0.1:$NODE_PORT'"
}

#######################################
# Returns count of currently up nodes.
#######################################
function get_count_of_up_nodes()
{
    local COUNT=0
    local NODE_ID

    for NODE_ID in $(seq 1 "$CCTL_COUNT_OF_NODES")
    do
        if [ "$(get_is_node_up "$NODE_ID")" == true ]; then
            COUNT=$((COUNT + 1))
        fi
    done

    echo $COUNT
}

#######################################
# Returns flag indicating whether network is currently up.
#######################################
function get_is_net_up()
{
    # Presence of supervisord socket indicates true.
    local PATH_TO_SUPERVISOR_SOCKET=$(get_path_to_supervisord_sock)
    if [ -e "$PATH_TO_SUPERVISOR_SOCKET" ]; then
        echo true
    else
        echo false
    fi
}

#######################################
# Returns flag indicating whether a node is currently up.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_is_node_up()
{
    local NODE_ID=${1}

    local NODE_PORT=$(get_port_of_node_to_net_bind  "$NODE_ID")

    if grep -q "$NODE_PORT (LISTEN)" <<< "$(lsof -i -P -n)"; then
        echo true
    else
        echo false
    fi
}

#######################################
# Returns flag indicating whether a sidecar is currently up.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_is_sidecar_up()
{
    local NODE_ID=${1}

    local NODE_PORT=$(get_port_of_sidecar_main_server  "$NODE_ID")

    if grep -q "$NODE_PORT (LISTEN)" <<< "$(lsof -i -P -n)"; then
        echo true
    else
        echo false
    fi
}

#######################################
# Returns network known addresses.
# Arguments:
#   Network ordinal identifier.
#######################################
function get_network_known_addresses()
{
    local NODE_ID=${1}
    local RESULT

    # If a bootstrap node then return set of bootstraps.
    RESULT=$(get_bootstrap_known_address 1)
    if [ "$NODE_ID" -lt "$CCTL_COUNT_OF_BOOTSTRAP_NODES" ]; then
        for IDX in $(seq 2 "$CCTL_COUNT_OF_BOOTSTRAP_NODES")
        do
            RESULT=$RESULT","$(get_bootstrap_known_address "$IDX")
        done
    # If a non-bootstrap node then return full set of nodes.
    # Note: could be modified to return full set of spinning nodes.
    else
        for IDX in $(seq 2 "$NODE_ID")
        do
            RESULT=$RESULT","$(get_bootstrap_known_address "$IDX")
        done
    fi

    echo "$RESULT"
}

#######################################
# Returns ordinal identifier of a random validator node able to be used for deploy dispatch.
# Arguments:
#   Network ordinal identifier.
#######################################
function get_node_for_dispatch()
{
    for NODE_ID in $(seq 1 "$CCTL_COUNT_OF_NODES" | shuf)
    do
        if [ "$(get_is_node_up "$NODE_ID")" = true ]; then
            echo "$NODE_ID"
            break
        fi
    done
}

#######################################
# Calculates a node's default staking weight.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_node_staking_weight()
{
    local NODE_ID=${1}

    echo $((CCTL_VALIDATOR_BASE_WEIGHT + NODE_ID))
}

#######################################
# Calculate port for a given base port, network id, and optional node id.
# Arguments:
#   Base starting port.
#   Node ordinal identifier.
#######################################
function get_port()
{
    local BASE_PORT=${1}
    local NODE_ID=${2:-$(get_node_for_dispatch)}

    echo $((BASE_PORT + 100 + NODE_ID))
}

#######################################
# Calculates a node's binary port.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_port_of_node_binary_server()
{
    local NODE_ID=${1}

    if ((${#CSPR_BASE_PORT_BINARY[@]})); then
        get_port "$CSPR_BASE_PORT_BINARY" "$NODE_ID"
    else
        get_port "$CCTL_BASE_PORT_NODE_BINARY" "$NODE_ID"
    fi
}

#######################################
# Calculates a node's REST port.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_port_of_node_rest_server()
{
    local NODE_ID=${1}

    if ((${#CSPR_BASE_PORT_REST[@]})); then
        get_port "$CSPR_BASE_PORT_REST" "$NODE_ID"
    else
        get_port "$CCTL_BASE_PORT_NODE_REST" "$NODE_ID"
    fi
}

#######################################
# Calculates a node's SSE port.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_port_of_node_sse_server()
{
    local NODE_ID=${1}

    if ((${#CSPR_BASE_PORT_SSE[@]})); then
        get_port "$CSPR_BASE_PORT_SSE" "$NODE_ID"
    else
        get_port "$CCTL_BASE_PORT_NODE_SSE" "$NODE_ID"
    fi
}

#######################################
# Returns network bind port.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_port_of_node_to_net_bind()
{
    local NODE_ID=${1}

    if ((${#CSPR_BASE_PORT_NETWORK[@]})); then
        get_port "$CSPR_BASE_PORT_NETWORK" "$NODE_ID"
    else
        get_port "$CCTL_BASE_PORT_NODE_NETWORK" "$NODE_ID"
    fi
}

#######################################
# Calculates a sidecar's main (RPC) port.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_port_of_sidecar_main_server ()
{
    local NODE_ID=${1}

    if ((${#CSPR_BASE_PORT_RPC[@]})); then
        get_port "$CSPR_BASE_PORT_RPC" "$NODE_ID"
    else
        get_port "$CCTL_BASE_PORT_SIDECAR_MAIN" "$NODE_ID"
    fi
}

#######################################
# Calculates a sidecar's speculative execution port.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_port_of_sidecar_speculative_exec_server()
{
    local NODE_ID=${1}

    if ((${#CSPR_BASE_PORT_SPEC_EXEC[@]})); then
        get_port "$CSPR_BASE_PORT_SPEC_EXEC" "$NODE_ID"
    else
        get_port "$CCTL_BASE_PORT_SIDECAR_SPEC_EXEC" "$NODE_ID"
    fi
}

#######################################
# Returns set of nodes within a process group.
# Arguments:
#   Process group identifier.
#######################################
function get_process_group_members()
{
    local PROCESS_GROUP=${1}

    local SEQ_END
    local SEQ_START

    # Set range.
    if [ "$PROCESS_GROUP" == "$CCTL_PROCESS_GROUP_1" ]; then
        SEQ_START=1
        SEQ_END=$CCTL_COUNT_OF_BOOTSTRAP_NODES

    elif [ "$PROCESS_GROUP" == "$CCTL_PROCESS_GROUP_2" ]; then
        SEQ_START=$(($CCTL_COUNT_OF_BOOTSTRAP_NODES + 1))
        SEQ_END=$CCTL_COUNT_OF_GENESIS_NODES

    elif [ "$PROCESS_GROUP" == "$CCTL_PROCESS_GROUP_3" ]; then
        SEQ_START=$(($CCTL_COUNT_OF_GENESIS_NODES + 1))
        SEQ_END=$CCTL_COUNT_OF_NODES
    fi

    # Set members of process group.
    local RESULT=""
    for NODE_ID in $(seq "$SEQ_START" "$SEQ_END")
    do
        if [ "$NODE_ID" -gt "$SEQ_START" ]; then
            RESULT=$RESULT", "
        fi
        RESULT=$RESULT$(get_process_name_of_node "$NODE_ID")
        RESULT=$RESULT", "
        RESULT=$RESULT$(get_process_name_of_sidecar "$NODE_ID")
    done

    echo "$RESULT"
}

#######################################
# Returns name of a daemonized node process within a group.
# Arguments:
#   Network ordinal identifier.
#   Node ordinal identifier.
#######################################
function get_process_name_of_node()
{
    local NODE_ID=${1}

    echo "cctl-node-$NODE_ID"
}

#######################################
# Returns name of a daemonized node process within a group.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_process_name_of_node_in_group()
{
    local NODE_ID=${1}

    local PROCESS_NAME=$(get_process_name_of_node "$NODE_ID")
    local PROCESS_GROUP_NAME=$(get_process_name_of_node_group "$NODE_ID")

    echo "$PROCESS_GROUP_NAME:$PROCESS_NAME"
}

#######################################
# Returns name of a daemonized node process group.
# Arguments:
#   Network ordinal identifier.
#   Node ordinal identifier.
#######################################
function get_process_name_of_node_group()
{
    local NODE_ID=${1}

    if [ "$NODE_ID" -le "$CCTL_COUNT_OF_BOOTSTRAP_NODES" ]; then
        echo "$CCTL_PROCESS_GROUP_1"
    elif [ "$NODE_ID" -le "$CCTL_COUNT_OF_GENESIS_NODES" ]; then
        echo "$CCTL_PROCESS_GROUP_2"
    else
        echo "$CCTL_PROCESS_GROUP_3"
    fi
}

#######################################
# Returns name of a daemonized sidecar process.
# Arguments:
#   Network ordinal identifier.
#   Node ordinal identifier.
#######################################
function get_process_name_of_sidecar()
{
    local NODE_ID=${1}

    echo "cctl-node-$NODE_ID-sidecar"
}

#######################################
# Returns name of a daemonized sidecar process within a group.
# Arguments:
#   Node ordinal identifier.
#######################################
function get_process_name_of_sidecar_in_group()
{
    local NODE_ID=${1}

    local PROCESS_NAME=$(get_process_name_of_sidecar "$NODE_ID")
    local PROCESS_GROUP_NAME=$(get_process_name_of_node_group "$NODE_ID")

    echo "$PROCESS_GROUP_NAME:$PROCESS_NAME"
}
