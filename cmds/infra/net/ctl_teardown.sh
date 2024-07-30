#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-net-teardown

    DESCRIPTION
    ----------------------------------------------------------------
    Tears down network assets - including active processes.

    NOTES
    ----------------------------------------------------------------
    Both static (e.g. config files) and dynamic (e.g. active processes)
    assets will be torn down.
    "
}

function _main()
{
    log "Network teardown -> begins"
    log_break

    _teardown_net
    log "Network processes -> stopped"

    _teardown_assets
    log "Network assets -> deleted"

    log_break
    log "Network teardown -> complete"
}

function _teardown_net()
{
    local PATH_TO_SUPERVISOR_CONFIG=$(get_path_to_supervisord_cfg)
    local PATH_TO_SUPERVISOR_SOCKET=$(get_path_to_supervisord_sock)

    if [ -e "$PATH_TO_SUPERVISOR_SOCKET" ]; then
        supervisorctl -c "$PATH_TO_SUPERVISOR_CONFIG" shutdown > /dev/null 2>&1 || true
        sleep 2.0
    fi
}

function _teardown_assets()
{
    local _PATH_TO_ASSETS=$(get_path_to_assets)

    if [ -d "$_PATH_TO_ASSETS" ]; then
        rm -rf "$_PATH_TO_ASSETS"
    fi
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
    log_break
    _main
    log_break
fi
