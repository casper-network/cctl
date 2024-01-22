#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-await-until-era-n

    DESCRIPTION
    ----------------------------------------------------------------
    Tracks chain and exits when chain has progressed to a specific future era.

    ARGS
    ----------------------------------------------------------------
    height      Future block height to await.
    "
}

function _main()
{
    local FUTURE=${1}
    local CURRENT=$(get_chain_era)
    log "current era = $CURRENT :: future era = $FUTURE"

    while [ "$CURRENT" -lt "$FUTURE" ];
    do
        log "awaiting future era :: sleeping 10 seconds"
        sleep 2.0
        CURRENT=$(get_chain_era)
    done

    log "current era = $CURRENT :: the future arrived !"
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _ERA
unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in        
        help) _HELP="show" ;;
        era) _ERA=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main $_ERA
fi
