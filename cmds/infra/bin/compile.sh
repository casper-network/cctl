#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-bin-compile

    DESCRIPTION
    ----------------------------------------------------------------
    Compiles complete set of binaries and smart contracts.

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

    source "$CCTL"/cmds/infra/bin/compile_client.sh mode="$MODE"
    source "$CCTL"/cmds/infra/bin/compile_contracts.sh
    source "$CCTL"/cmds/infra/bin/compile_node.sh mode="$MODE"
    source "$CCTL"/cmds/infra/bin/compile_node_launcher.sh mode="$MODE"
    source "$CCTL"/cmds/infra/bin/compile_sidecar.sh mode="$MODE"
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
