#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-view-node-storage

    DESCRIPTION
    ----------------------------------------------------------------
    Displays node storage metrics ... either all nodes or an individual node.

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
        for NODE_ID in $(seq 1 "$(get_count_of_nodes)")
        do
            if [ $(get_node_is_up "$NODE_ID") = true ]; then
                echo "------------------------------------------------------------------------------------------------------------------------------------"
                _display_storage "$NODE_ID"
            fi
        done
        echo "------------------------------------------------------------------------------------------------------------------------------------"
    else
        if [ $(get_node_is_up "$NODE_ID") = true ]; then
            _display_storage "$NODE_ID"
        else
            log_warning "node $NODE_ID is not running"
        fi
    fi
}

function _display_storage()
{
    local NODE_ID=${1}
    
    local OS_TYPE="$(get_os)"
    local PATH_TO_NODE_STORAGE="$(get_path_to_node "$NODE_ID")/storage"

    log "node #$NODE_ID :: storage @ $PATH_TO_NODE_STORAGE"

    if [[ $OS_TYPE == "$_OS_LINUX*" ]]; then
        ll "$PATH_TO_NODE_STORAGE"/"$CCTL_NET_NAME"
    elif [[ $OS_TYPE == "$_OS_MACOSX" ]]; then
        ls -lG "$PATH_TO_NODE_STORAGE"/"$CCTL_NET_NAME"
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
    _main "${_NODE_ID:-"all"}"
fi
