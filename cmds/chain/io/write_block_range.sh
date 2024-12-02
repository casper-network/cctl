#!/usr/bin/env bash

function _help() {
    echo "
    COMMAND
    ----------------------------------------------------------------
    cctl-chain-io-write-block-range

    DESCRIPTION
    ----------------------------------------------------------------
    Writes to file system a range of blocks pulled from a CCTL network.

    ARGS
    ----------------------------------------------------------------
    from    Height of block at which block downloading begins.
    to      Height of block at which block downloading ends.
    "
}

function _main()
{
    local BLOCK_HASH
    local BLOCK_HEIGHT
    local BLOCK_HEIGHT_FROM=${1}
    local BLOCK_HEIGHT_TO=${2}
    local OUTPUT_DIR=${3}

    rm -rf $OUTPUT_DIR
    mkdir -p $OUTPUT_DIR

    for BLOCK_HEIGHT in $(seq -w $BLOCK_HEIGHT_FROM $BLOCK_HEIGHT_TO)
    do
        BLOCK_HASH=$(_get_block_hash $BLOCK_HEIGHT)
        _write_block $BLOCK_HEIGHT $BLOCK_HASH $OUTPUT_DIR
    done
}

function _write_block()
{
    local BLOCK_HASH=${2}
    local BLOCK_HEIGHT=${1}
    local OUTPUT_DIR=${3}
    local BLOCK_FPATH="$OUTPUT_DIR/block-$BLOCK_HEIGHT-$BLOCK_HASH.json"
    local NODE_ADDRESS_CURL=$(get_address_of_sidecar_main_server_for_curl)

    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        --header 'Content-Type: application/json' \
        --request POST "$NODE_ADDRESS_CURL" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "chain_get_block",
            "params": {
                "block_identifier": {
                    "Hash": "'"$BLOCK_HASH"'"
                }
            }
        }' \
    | jq '.result.block_with_signatures' \
    >> $BLOCK_FPATH
}

function _get_block_hash()
{
    local BLOCK_HEIGHT=$(expr ${1} + 0)
    local NODE_ADDRESS_CURL=$(get_address_of_sidecar_main_server_for_curl)

    curl $CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES \
        --header 'Content-Type: application/json' \
        --request POST "$NODE_ADDRESS_CURL" \
        --data-raw '{
            "id": 1,
            "jsonrpc": "2.0",
            "method": "chain_get_block",
            "params": {
                "block_identifier": {
                    "Height": '"$BLOCK_HEIGHT"'
                }
            }
        }' \
        | jq '.result.block_with_signatures.block.Version2.hash' \
        | sed -e 's/^"//' -e 's/"$//'
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

source "$CCTL"/utils/main.sh

unset _OUTPUT_DIR
unset _HEIGHT_FROM
unset _HEIGHT_TO
unset _HELP

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        from) _HEIGHT_FROM=${VALUE} ;;
        help) _HELP="show" ;;
        out) _OUTPUT_DIR=${VALUE} ;;
        to) _HEIGHT_TO=${VALUE} ;;
        *)
    esac
done

if [ "${_HELP:-""}" = "show" ]; then
    _help
else
    _main \
        "${_HEIGHT_FROM:-0}" \
        "${_HEIGHT_TO:-50}" \
        "${_OUTPUT_DIR:-"$(get_path_to_assets)/io"}"
fi
