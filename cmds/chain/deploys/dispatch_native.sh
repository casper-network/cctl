#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-tx-exec-transfer

    DESCRIPTION
    ----------------------------------------------------------------
    Dispatches a native transfer to a running node.

    ARGS
    ----------------------------------------------------------------
    amount          d
    interval        d
    node            d
    transfers       d
    user            d
    verbose         d

    DEFAULTS
    ----------------------------------------------------------------
    amount          $CCTL_DEFAULT_TRANSFER_AMOUNT
    interval        0.01 seconds
    node            random
    transfers       100
    user            1
    verbose         true
    "
}

function _main()
{
    local AMOUNT=${1}
    local INTERVAL=${2}
    local NODE_ID=${3}
    local TRANSFERS=${4}
    local USER_ID=${5}
    local VERBOSE=${6}

    local CHAIN_NAME=$CCTL_NET_NAME
    local CP1_SECRET_KEY=$(get_path_to_secret_key "$CCTL_ACCOUNT_TYPE_FAUCET")
    local CP1_ACCOUNT_KEY=$(get_account_key "$CCTL_ACCOUNT_TYPE_FAUCET")
    local CP2_ACCOUNT_KEY=$(get_account_key "$CCTL_ACCOUNT_TYPE_USER" "$USER_ID")
    local DISPATCH_ATTEMPTS=0
    local DISPATCH_NODE_ADDRESS
    local GAS_PAYMENT=$CCTL_DEFAULT_GAS_PAYMENT
    local NODE_ADDRESS
    local OUTPUT
    local PATH_TO_CLIENT=$(get_path_to_client)
    local SUCCESSFUL_DISPATCH_COUNT=0

    if [ $VERBOSE == true ]; then
        log "dispatching $TRANSFERS native transfers"
        log "... chain=$CHAIN_NAME"
        log "... transfer amount=$AMOUNT"
        log "... transfer interval=$INTERVAL (s)"
        log "... counter-party 1 public key=$CP1_ACCOUNT_KEY"
        log "... counter-party 2 public key=$CP2_ACCOUNT_KEY"
        log "... dispatched deploys:"
    fi

    # Loop whilst dispatch attempts < total to dispatch. 
    while [ $DISPATCH_ATTEMPTS -lt "$TRANSFERS" ]; do
        # Increment counts.
        DISPATCH_ATTEMPTS=$((DISPATCH_ATTEMPTS + 1))
        DISPATCH_NODE_ADDRESS=${NODE_ADDRESS:-$(get_node_address_rpc)}

        # Dispatch deploy.
        OUTPUT=$(
            $PATH_TO_CLIENT transfer \
                --chain-name "$CHAIN_NAME" \
                --node-address "$DISPATCH_NODE_ADDRESS" \
                --payment-amount "$GAS_PAYMENT" \
                --ttl "5minutes" \
                --secret-key "$CP1_SECRET_KEY" \
                --amount "$AMOUNT" \
                --target-account "$CP2_ACCOUNT_KEY" \
                --transfer-id $((DISPATCH_ATTEMPTS + 1))
            )

        # Process output.
        if [[ $? -eq 0 ]]; then
            SUCCESSFUL_DISPATCH_COUNT=$((SUCCESSFUL_DISPATCH_COUNT + 1))
            DEPLOY_HASH=$(echo $OUTPUT | jq '.result.deploy_hash' | sed -e 's/^"//' -e 's/"$//')
            if [ $VERBOSE == true ]; then
                log "... #$DISPATCH_ATTEMPTS :: $DISPATCH_NODE_ADDRESS :: $DEPLOY_HASH"
            fi
        else
            if [ $VERBOSE == true ]; then
                log "... #$DISPATCH_ATTEMPTS :: $DISPATCH_NODE_ADDRESS :: FAILED to send"
            fi
        fi

        # Pause.
        sleep "$INTERVAL"
    done


}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _AMOUNT
unset _HELP
unset _INTERVAL
unset _NODE_ID
unset _TRANSFERS
unset _USER_ID
unset _VERBOSE

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        amount) _AMOUNT=${VALUE} ;;
        help) _HELP="show" ;;
        interval) _INTERVAL=${VALUE} ;;
        node) _NODE_ID=${VALUE} ;;
        transfers) _TRANSFERS=${VALUE} ;;
        user) _USER_ID=${VALUE} ;;
        verbose) _VERBOSE=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main \
        "${_AMOUNT:-$CCTL_DEFAULT_TRANSFER_AMOUNT}" \
        "${_INTERVAL:-0.01}" \
        "${_NODE_ID:-"random"}" \
        "${_TRANSFERS:-100}" \
        "${_USER_ID:-1}" \
        ${_VERBOSE:-true}
fi
