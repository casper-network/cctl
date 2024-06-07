#!/usr/bin/env bash

declare _DEPRECATED_ENDPOINTS=(
    "account_put_deploy"
    "info_get_deploy"
    "state_get_item"
)

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-sidecar-write-rpc-schema

    DESCRIPTION
    ----------------------------------------------------------------
    Writes to resources the sidecar JSON RPC schema and endpoints.
    "
}

function _main()
{
    local PATH_TO_RESOURCES=$(get_path_to_static_resources)

    rm $PATH_TO_RESOURCES/rpc-schema/*.json
    rm $PATH_TO_RESOURCES/rpc-schema/deprecated/*.json

    _write_schema "$CCTL"/resources/rpc-schema
    _write_endpoints "$CCTL"/resources/rpc-schema
}

function _write_schema()
{
    local PATH_TO_RESOURCES=${1}

    log "Writing schema:"
    log "... rpc.discover.json"

    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        -s \
        --header 'Content-Type: application/json' \
        --request POST "$(get_address_of_sidecar_main_server_for_curl)" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "rpc.discover"
        }' \
        | jq '.result.schema' \
        > "$CCTL"/resources/rpc-schema/rpc.discover.json
}

function _write_endpoints()
{
    local PATH_TO_RESOURCES=${1}
    local PATH_TO_OUTPUT

    local ENDPOINT
    local ENDPOINTS=$(
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --header 'Content-Type: application/json' \
            --request POST "$(get_address_of_sidecar_main_server_for_curl)" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "rpc.discover"
            }' \
            | jq -r '.result.schema.methods[].name' \
            | sort
    )

    # Write active.
    log "Writing active endpoints:"
    for ENDPOINT in $ENDPOINTS
    do
        if [[ " ${_DEPRECATED_ENDPOINTS[*]} " != *"$ENDPOINT"* ]];
        then
            PATH_TO_OUTPUT="$CCTL"/resources/rpc-schema/$ENDPOINT.json
            _write_endpoint "$ENDPOINT" "$PATH_TO_OUTPUT"
        fi
    done

    # Write deprecated.
    log "Writing deprecated endpoints:"
    for ENDPOINT in $ENDPOINTS
    do
        if [[ " ${_DEPRECATED_ENDPOINTS[*]} " == *"$ENDPOINT"* ]];
        then
            PATH_TO_OUTPUT="$CCTL"/resources/rpc-schema/deprecated/$ENDPOINT.json
            _write_endpoint "$ENDPOINT" "$PATH_TO_OUTPUT"
            log "... $ENDPOINT.json"
        fi
    done
}

function _write_endpoint()
{
    local ENDPOINT=${1}
    local PATH_TO_OUTPUT=${2}

    log "... $ENDPOINT.json"
    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        --header 'Content-Type: application/json' \
        --request POST "$(get_address_of_sidecar_main_server_for_curl)" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "rpc.discover"
        }' \
        | jq '.result.schema.methods[] | select(.name == "'"$ENDPOINT"'")' \
        > $PATH_TO_OUTPUT
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
