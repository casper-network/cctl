#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-net-status

    DESCRIPTION
    ----------------------------------------------------------------
    Displays network status.
    "
}

function _main()
{
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_net_supervisord_cfg)

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

