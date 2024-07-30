#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-tx-mint-transfer-batch

    DESCRIPTION
    ----------------------------------------------------------------
    Dispatches a set of transfer batches into network.

    ARGS
    ----------------------------------------------------------------
    batch           Ordinal identifier of batch to be dispatched.
    interval        Time interval (seconds) between each transfer. Optional.
    node            Either ordinal identifier of a running node or random. Optional.
    type            Type of transfer, native or wasm. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    batch           1
    interval        0.01 seconds
    node            random
    type            native
    "
}

function _main()
{
    local BATCH_ID=${1}
    local INTERVAL=${2}
    local NODE_ID=${3}
    local TYPEOF=${4}

    local DISPATCH_NODE_ADDRESS
    local NODE_ADDRESS
    local PATH_TO_CLIENT=$(get_path_to_node_client)
    local PATH_TO_TX
    local PATH_TO_TX_BATCH
    local PATH_TO_TX_ROOT="$(get_path_to_assets)"/transactions
    local TX_ID

    # Set node address.
    if [ "$NODE_ID" == "random" ]; then
        unset NODE_ADDRESS
    elif [ "$NODE_ID" -eq 0 ]; then
        NODE_ADDRESS=$(get_address_of_sidecar_main_server)
    else
        NODE_ADDRESS=$(get_address_of_sidecar_main_server "$NODE_ID")
    fi

    log_break
    log "dispatching $BATCH_COUNT batches of $BATCH_SIZE $TYPEOF transfers per user to the file system"
    log_break

    # Dispatch deploy batch.
    PATH_TO_TX_BATCH="$PATH_TO_TX_ROOT"/transfer-$TYPEOF/batch-$BATCH_ID    
    if [ ! -d "$PATH_TO_TX_BATCH" ]; then
        log "ERROR: no batch exists on file system - have you written it ?"
    else
        TX_ID=0
        for USER_ID in $(seq 1 "$CCTL_COUNT_OF_USERS")
        do
            for TRANSFER_ID in $(seq 1 100000)
            do
                PATH_TO_TX="$PATH_TO_TX_BATCH"/user-"$USER_ID"/transfer-$TRANSFER_ID.json
                if [ ! -f "$PATH_TO_TX" ]; then
                    break
                else
                    TX_ID=$((TX_ID + 1)) 
                    DISPATCH_NODE_ADDRESS=${NODE_ADDRESS:-$(get_address_of_sidecar_main_server)}
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
unset _TYPEOF

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        batch) _BATCH_ID=${VALUE} ;;
        help) _HELP="show" ;;
        interval) _INTERVAL=${VALUE} ;;
        node) _NODE_ID=${VALUE} ;;
        type) _TYPEOF=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main \
        "${_BATCH_ID:-1}" \
        "${_INTERVAL:-0.01}" \
        "${_NODE_ID:-"random"}" \
        "${_TYPEOF:-"native"}"
fi
