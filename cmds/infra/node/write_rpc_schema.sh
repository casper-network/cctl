#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-infra-node-write-rpc-schema

    DESCRIPTION
    ----------------------------------------------------------------
    Writes to resources a node's JSON RPC schema and endpoints.
    "
}

function _main()
{
    local PATH_TO_RESOURCES=$(get_path_to_resources)

    rm $PATH_TO_RESOURCES/rpc-schema/*.json

    _write_schema $PATH_TO_RESOURCES
    _write_endpoints $PATH_TO_RESOURCES
}

function _write_schema()
{
    local PATH_TO_RESOURCES=${1}

    log "writing -> schema.json"

    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        -s \
        --header 'Content-Type: application/json' \
        --request POST "$(get_node_address_rpc_for_curl)" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "rpc.discover"
        }' \
        | jq '.result.schema' \
        > $CCTL_RESOURCES/rpc-schema/schema.json
}

function _write_endpoints()
{
    local PATH_TO_RESOURCES=${1}

    local ENDPOINTS=$(
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --header 'Content-Type: application/json' \
            --request POST "$(get_node_address_rpc_for_curl)" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "rpc.discover"
            }' \
            | jq -r '.result.schema.methods[].name' \
            | sort
    )

    for ENDPOINT in $ENDPOINTS
    do
        log "writing -> $ENDPOINT.json"
        curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
            --header 'Content-Type: application/json' \
            --request POST "$(get_node_address_rpc_for_curl)" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "rpc.discover"
            }' \
            | jq '.result.schema.methods[] | select(.name == "'"$ENDPOINT"'")' \
            > $CCTL_RESOURCES/rpc-schema/$ENDPOINT.json
    done
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
