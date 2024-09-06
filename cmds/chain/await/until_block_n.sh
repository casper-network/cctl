#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-await-until-block-n

    DESCRIPTION
    ----------------------------------------------------------------
    Tracks chain and exits when a chain has finialized a specific block in the future.

    ARGS
    ----------------------------------------------------------------
    height      Future block height to await.
    "
}

function _main()
{
    local FUTURE=${1}
    local CURRENT=$(get_chain_height)
    log "current block height = $CURRENT :: future block height = $FUTURE"

    while [ "$CURRENT" != "N/A" && "$CURRENT" -lt "$FUTURE" ];
    do
        log "awaiting future block :: sleeping 2 seconds"
        sleep 2.0
        CURRENT=$(get_chain_height)
    done

    log "current block height = $CURRENT :: the future arrived !"
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HEIGHT
unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in        
        help) _HELP="show" ;;
        height) _HEIGHT=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main $_HEIGHT
fi
