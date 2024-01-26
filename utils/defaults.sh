#!/usr/bin/env bash

# Set compilation target.
declare CCTL_COMPILE_TARGET=${CSPR_COMPILE_TARGET:-release}

# Set path -> working directory.
_CCTL_PATH_TO_WORKING_DIR="$( cd "$( dirname "${CCTL[0]}" )" && pwd )"

# Set path -> casper-client.
declare CCTL_PATH_TO_CASPER_CLIENT=${CSPR_PATH_TO_CASPER_CLIENT:-$_CCTL_PATH_TO_WORKING_DIR/casper-client-rs}

# Set path -> casper-node.
declare CCTL_PATH_TO_CASPER_NODE=${CSPR_PATH_TO_CASPER_NODE:-$_CCTL_PATH_TO_WORKING_DIR/casper-node}

# Set path -> casper-node launcher.
declare CCTL_PATH_TO_CASPER_NODE_LAUNCHER=${CSPR_PATH_TO_NODE_LAUNCHER:-$_CCTL_PATH_TO_WORKING_DIR/casper-node-launcher}
