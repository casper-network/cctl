#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-view-chain-deploy

    DESCRIPTION
    ----------------------------------------------------------------
    Renders on-chain deploy information.

    ARGS
    ----------------------------------------------------------------
    deploy       Identifier of a deploy (hash).
    "
}

function _main()
{
    local DEPLOY_ID=${1}

    $(get_path_to_node_client) get-deploy \
        --node-address "$(get_address_of_sidecar_main_server)" \
        "$DEPLOY_ID" \
        | jq '.result'
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _DEPLOY_ID
unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        deploy) _DEPLOY_ID=${VALUE} ;;
        help) _HELP="show" ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main $_DEPLOY_ID
fi
