#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-bin-compile-contracts

    DESCRIPTION
    ----------------------------------------------------------------
    Compiles test smart contracts.

    ARGS
    ----------------------------------------------------------------
    mode        Compilation mode: debug | release. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    mode        release
    "
}

function _main()
{
    pushd "$CCTL_CASPER_NODE_HOME" || \
        { echo "Could not find the casper-node repo - have you cloned it into your working directory?"; exit; }

    make setup-rs
    make build-contract-rs/activate-bid
    make build-contract-rs/add-bid
    make build-contract-rs/delegate
    make build-contract-rs/named-purse-payment
    make build-contract-rs/transfer-to-account-u512
    make build-contract-rs/undelegate
    make build-contract-rs/withdraw-bid
    make build-contract-rs/cctl-dictionary

    popd || exit
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main
fi
