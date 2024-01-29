#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-net-status

    DESCRIPTION
    ----------------------------------------------------------------
    Displays process status of each network node.
    "
}

function _main()
{
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_net_supervisord_cfg)

    supervisorctl -c "$PATH_TO_SUPERVISOR_CONFIG" status all || true
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

