#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-tx-dispatch-native-transfer-batch

    DESCRIPTION
    ----------------------------------------------------------------
    Dispatches a prepared set of native transfers into network.

    ARGS
    ----------------------------------------------------------------
    batch           Ordinal identifier of batch to be dispatched.
    interval        Time interval (seconds) between each transfer. Optional.
    node            Either ordinal identifier of a running node or random. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    batch           1
    interval        0.01 seconds
    node            random
    "
}

function _main()
{
    local BATCH_ID=${1}
    local INTERVAL=${2}
    local NODE_ID=${3}

    local DISPATCH_NODE_ADDRESS
    local NODE_ADDRESS
    local PATH_TO_CLIENT=$(get_path_to_client)
    local PATH_TO_TX
    local PATH_TO_TX_BATCH
    local PATH_TO_TX_ROOT="$(get_path_to_assets)"/transactions
    local TX_ID

    # Set node address.
    if [ "$NODE_ID" == "random" ]; then
        unset NODE_ADDRESS
    elif [ "$NODE_ID" -eq 0 ]; then
        NODE_ADDRESS=$(get_node_address_rpc)
    else
        NODE_ADDRESS=$(get_node_address_rpc "$NODE_ID")
    fi

    # Dispatch deploy batch.
    PATH_TO_TX_BATCH="$PATH_TO_TX_ROOT"/transfer-native/batch-$BATCH_ID
    if [ ! -d "$PATH_TO_TX_BATCH" ]; then
        log "ERROR: no batch exists on file system - have you prepared it ?"
    else
        TX_ID=0
        for USER_ID in $(seq 1 "$(get_count_of_users)")
        do
            for TRANSFER_ID in $(seq 1 100000)
            do
                PATH_TO_TX="$PATH_TO_TX_BATCH"/user-"$USER_ID"/transfer-$TRANSFER_ID.json
                if [ ! -f "$PATH_TO_TX" ]; then
                    break
                else
                    TX_ID=$((TX_ID + 1)) 
                    DISPATCH_NODE_ADDRESS=${NODE_ADDRESS:-$(get_node_address_rpc)}
                    DEPLOY_HASH=$(
                        $PATH_TO_CLIENT send-deploy \
                            --node-address "$DISPATCH_NODE_ADDRESS" \
                            --input "$PATH_TO_TX" \
                            | jq '.result.deploy_hash' \
                            | sed -e 's/^"//' -e 's/"$//'                                
                    )
                    log "tx #$TX_ID :: batch #$BATCH_ID :: user #$USER_ID :: $DEPLOY_HASH :: $DISPATCH_NODE_ADDRESS"
                    sleep "$INTERVAL"
                fi
            done
        done
    fi
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _BATCH_ID
unset _HELP
unset _INTERVAL
unset _NODE_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        batch) _BATCH_ID=${VALUE} ;;
        help) _HELP="show" ;;
        interval) _INTERVAL=${VALUE} ;;
        node) _NODE_ID=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main \
        "${_BATCH_ID:-1}" \
        "${_INTERVAL:-0.01}" \
        "${_NODE_ID:-"random"}"
fi
