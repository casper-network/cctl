#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-sidecar-view-config

    DESCRIPTION
    ----------------------------------------------------------------
    Displays a sidecar's configuration toml file.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of a node.
    "
}

function _main()
{
    local NODE_ID=${1}

    local PATH_TO_CONFIG="$(get_path_to_sidecar "$NODE_ID")/config/sidecar.toml"

    less $PATH_TO_CONFIG
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
    _main "$_NODE_ID"
fi
