#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-bin-compile-client

    DESCRIPTION
    ----------------------------------------------------------------
    Compiles client side cli program.

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
    local MODE=${1}

    local PATH_TO_REPO=$(get_path_to_working_directory)/casper-client-rs

    if [ ! -d "$PATH_TO_REPO" ]; then
        log "ERROR: casper-client-rs repo must be cloned into $(get_path_to_working_directory) before compilation can occur"
    else
        pushd "$PATH_TO_REPO"
        if [ "$MODE" = "debug" ]; then
            cargo build
        else
            cargo build --release
        fi
        popd || exit
    fi
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP
unset _MODE

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        mode) _MODE=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "${_MODE:-"release"}"
fi
