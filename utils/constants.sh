#!/usr/bin/env bash

# A type of actor representing a participating node.
export CCTL_ACCOUNT_TYPE_FAUCET="faucet"

# A type of actor representing a participating node.
export CCTL_ACCOUNT_TYPE_NODE="node"

# A type of actor representing a user.
export CCTL_ACCOUNT_TYPE_USER="user"

# Base RPC server port number.
export CCTL_BASE_PORT_RPC=11000

# Base JSON server port number.
export CCTL_BASE_PORT_REST=14000

# Base event server port number.
export CCTL_BASE_PORT_SSE=18000

# Base network server port number.
export CCTL_BASE_PORT_NETWORK=22000

# Base speculative execution RPC server port number.
export CCTL_BASE_PORT_SPEC_EXEC=25000

# Set of client side auction contracts.
export CCTL_CONTRACTS_CLIENT_AUCTION=(
    "activate_bid.wasm"
    "add_bid.wasm"
    "delegate.wasm"
    "undelegate.wasm"
    "withdraw_bid.wasm"
)

# Set of client side shared contracts.
export CCTL_CONTRACTS_CLIENT_SHARED=(
    "named_purse_payment.wasm"
)

# Set of client side transfer contracts.
export CCTL_CONTRACTS_CLIENT_TRANSFERS=(
    "transfer_to_account_u512.wasm"
)

# Default amount used when delegating.
export CCTL_DEFAULT_AUCTION_DELEGATE_AMOUNT=1000000000   # (1e9)

# Default era offset to apply when activating an upgrade.
export CCTL_DEFAULT_ERA_ACTIVATION_OFFSET=2

# Default motes to pay for consumed gas.
export CCTL_DEFAULT_GAS_PAYMENT=100000000000   # (1e11)

# Default amount used when making transfers.
export CCTL_DEFAULT_TRANSFER_AMOUNT=2500000000   # (1e9)

# Intitial balance of faucet account.
export CCTL_INITIAL_BALANCE_FAUCET=1000000000000000000000000000000000   # (1e33)

# Intitial balance of user account.
export CCTL_INITIAL_BALANCE_USER=1000000000000000000000000000000000   # (1e33)

# Intitial balance of validator account.
export CCTL_INITIAL_BALANCE_VALIDATOR=1000000000000000000000000000000000   # (1e33)

# Intitial delegation amount of a user account.
export CCTL_INITIAL_DELEGATION_AMOUNT=1000000000000000000   # (1e18)

# Base weight applied to a validator at genesis.
export CCTL_VALIDATOR_BASE_WEIGHT=1000000000000000000   # (1e18)

# Name of local cctl network.
export CCTL_NET_NAME=casper-dev-cctl

# Name of process group: boostrap validators.
export CCTL_PROCESS_GROUP_1=validator-group-1

# Name of process group: genesis validators.
export CCTL_PROCESS_GROUP_2=validator-group-2

# Name of process group: non-genesis validators.
export CCTL_PROCESS_GROUP_3=validator-group-3

# cURL arguments which are used when talking to the CCTL nodes.
# We need to allow retires and limit the default timeouts because not all
# testing scenarios guarantee that nodes are responsive immediately, which may
# lead to the test being stuck. The exponential backoff delay used for reties
# is replaced with a constant 1 sec. delay.
# In addition, we don't want cURL to put anything on the standard output.
export CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES="--max-time 4 --connect-timeout 2 --retry 20 --retry-connrefused --retry-delay 1 -s"
