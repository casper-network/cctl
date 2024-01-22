#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-await-n-eras

    DESCRIPTION
    ----------------------------------------------------------------
    Tracks chain and exits N eras in the future.

    ARGS
    ----------------------------------------------------------------
    offset      Number of eras to await.  Optional.

    DEFAULTS
    ----------------------------------------------------------------
    offset      1
    "
}

function _main()
{
    local OFFSET=${1}

    local CURRENT
    local FUTURE

    CURRENT=$(get_chain_era)
    FUTURE=$((CURRENT + OFFSET))
    log "current era = $CURRENT :: future era = $FUTURE"

    while [ "$CURRENT" -lt "$FUTURE" ];
    do
        log "awaiting future era :: sleeping 10 seconds"
        sleep 10.0
        CURRENT=$(get_chain_era)
    done

    log "current era = $CURRENT :: the future arrived !"
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP
unset _OFFSET

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in        
        help) _HELP="show" ;;
        offset) _OFFSET=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main ${OFFSET:-1} 
fi
