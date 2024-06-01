#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-node-view-metrics

    DESCRIPTION
    ----------------------------------------------------------------
    Displays node metrics ... either all or individual.

    ARGS
    ----------------------------------------------------------------
    node        Ordinal identifier of a node. Optional.
    metric      Metric to display. Optional.

    DEFAULTS
    ----------------------------------------------------------------
    node        all
    metric      all
    "
}

function _main()
{
    local NODE_ID=${1}
    local METRIC=${2}

    if [ "$NODE_ID" = "all" ]; then
        for NODE_ID in $(seq 1 "$CCTL_COUNT_OF_NODES")
        do
            if [ $(get_node_is_up "$NODE_ID") = true ]; then
                _display_metric "$NODE_ID" "$METRIC"
            fi
        done
    else
        if [ $(get_node_is_up "$NODE_ID") = true ]; then
            _display_metric "$NODE_ID" "$METRIC"
        else
            log_warning "node $NODE_ID is not running"
        fi
    fi
}

function _display_metric()
{
    local NODE_ID=${1}
    local METRIC=${2}

    local ENDPOINT="$(get_node_address_rest "$NODE_ID")"/metrics

    log "------------------------------------------------------------------------------------------------------"
    if [ "$METRIC" = "all" ]; then
        log "node $NODE_ID metrics"
    else
        log "node $NODE_ID metrics :: $METRIC*"
    fi
    log "------------------------------------------------------------------------------------------------------"

    if [ "$METRIC" = "all" ]; then
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --location \
            --request GET "$ENDPOINT" \
            | grep -o '^[^#]*' \
            | sort
    else
        echo "$(curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
                    -s --location --request GET "$ENDPOINT" \
                    | grep "$METRIC" \
                    | grep -o '^[^#]*' \
                    | sort
                )"
    fi
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _HELP
unset _METRIC
unset _NODE_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        help) _HELP="show" ;;
        metric) _METRIC=${VALUE} ;;
        node) _NODE_ID=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main "${_NODE_ID:-"all"}" "${_METRIC:-"all"}"
fi
