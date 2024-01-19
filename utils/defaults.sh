#!/usr/bin/env bash

# Set default type of daemon to run.
export CCTL_DAEMON_TYPE=${CCTL_DAEMON_TYPE:-supervisord}

# Set default compilation target.
export CCTL_COMPILE_TARGET=${CCTL_COMPILE_TARGET:-release}

# Set default logging output format.
export CCTL_NODE_LOG_FORMAT=${CCTL_NODE_LOG_FORMAT:-json}
