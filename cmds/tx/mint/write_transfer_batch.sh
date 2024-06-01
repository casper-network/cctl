#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-tx-prepare-batch-of-native-transfers

    DESCRIPTION
    ----------------------------------------------------------------
    Prepares a set of native transfers to be dispatached into a network.

    ARGS
    ----------------------------------------------------------------
    amount          Amount (motes) to transfer. Optional.
    count           Number of transactions per batch. Optional.
    size            Batch size. Optional.
    ttl             Transfer time to live. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    amount          $CCTL_DEFAULT_TRANSFER_AMOUNT
    count           5
    size            200
    ttl             30minutes
    "
}

function _main()
{
    local AMOUNT=${1}
    local BATCH_COUNT=${2}
    local BATCH_SIZE=${3}
    local DEPLOY_TTL=${4}
    local TYPEOF=${5}

    local CHAIN_NAME=$CCTL_NET_NAME
    local CP1_SECRET_KEY=$(get_path_to_secret_key "$CCTL_ACCOUNT_TYPE_FAUCET")
    local CP2_ACCOUNT_KEY
    local CP2_ACCOUNT_HASH
    local GAS_PAYMENT=$CCTL_DEFAULT_GAS_PAYMENT
    local PATH_TO_CLIENT=$(get_path_to_node_client)
    local PATH_TO_CONTRACT="$(get_path_to_assets)"/bin/transfer_to_account_u512.wasm
    local PATH_TO_TX
    local PATH_TO_TX_DIR
    local PATH_TO_TX_ROOT_DIR="$(get_path_to_assets)"/transactions
    local USER_ID

    log_break
    log "writing $BATCH_COUNT batches of $BATCH_SIZE $TYPEOF transfers per user to the file system"
    log_break

    if [ -d "$PATH_TO_TX_ROOT_DIR"/transfer-"$TYPEOF" ]; then
        rm -rf "$PATH_TO_TX_ROOT_DIR"/transfer-"$TYPEOF"
    fi

    # Enumerate set of batches.
    for BATCH_ID in $(seq 1 "$BATCH_COUNT")
    do
        log "batch #$BATCH_ID"

        # Enumerate set of users.
        for USER_ID in $(seq 1 "$(get_count_of_users)")
        do
            log "... user #$USER_ID"

            # Set user account info.
            CP2_ACCOUNT_KEY=$(get_account_key "$CCTL_ACCOUNT_TYPE_USER" "$USER_ID")
            CP2_ACCOUNT_HASH=$(get_account_hash "$CP2_ACCOUNT_KEY")

            # Set path to output directory.
            PATH_TO_TX_DIR="$PATH_TO_TX_ROOT_DIR"/transfer-"$TYPEOF"/batch-"$BATCH_ID"/user-"$USER_ID"
            mkdir -p "$PATH_TO_TX_DIR"

            # Enumerate set of transfers to prepare.
            for TRANSFER_ID in $(seq 1 "$BATCH_SIZE")
            do
                # Set path to tx.
                PATH_TO_TX="$PATH_TO_TX_DIR"/transfer-$TRANSFER_ID.json

                # Set tx.
                if [ $TYPEOF == "wasm" ]; then
                    $PATH_TO_CLIENT make-deploy \
                        --output "$PATH_TO_TX" \
                        --chain-name "$CHAIN_NAME" \
                        --payment-amount "$GAS_PAYMENT" \
                        --ttl "$DEPLOY_TTL" \
                        --secret-key "$CP1_SECRET_KEY" \
                        --session-arg "$(get_cl_arg_u512 'amount' "$AMOUNT")" \
                        --session-arg "$(get_cl_arg_account_hash 'target' "$CP2_ACCOUNT_HASH")" \
                        --session-path "$PATH_TO_CONTRACT" > \
                        /dev/null 2>&1
                else
                    $PATH_TO_CLIENT make-transfer \
                        --output "$PATH_TO_TX" \
                        --chain-name "$CHAIN_NAME" \
                        --payment-amount "$GAS_PAYMENT" \
                        --ttl "$DEPLOY_TTL" \
                        --secret-key "$CP1_SECRET_KEY" \
                        --transfer-id $BATCH_ID$TRANSFER_ID \
                        --amount "$AMOUNT" \
                        --target-account "account-hash-$CP2_ACCOUNT_HASH" > \
                        /dev/null 2>&1
                fi
            done
        done
    done
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _AMOUNT
unset _BATCH_COUNT
unset _BATCH_SIZE
unset _DEPLOY_TTL
unset _HELP
unset _TYPEOF

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        amount) _AMOUNT=${VALUE} ;;
        count) _BATCH_COUNT=${VALUE} ;;
        help) _HELP="show" ;;
        size) _BATCH_SIZE=${VALUE} ;;
        ttl) _DEPLOY_TTL=${VALUE} ;;
        type) _TYPEOF=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main \
        "${_AMOUNT:-$CCTL_DEFAULT_TRANSFER_AMOUNT}" \
        "${_BATCH_COUNT:-5}" \
        "${_BATCH_SIZE:-200}" \
        "${_DEPLOY_TTL:-"30minutes"}" \
        "${_TYPEOF:-"native"}"
fi
