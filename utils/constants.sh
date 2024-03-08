#!/usr/bin/env bash

# A type of actor representing a participating node.
declare CCTL_ACCOUNT_TYPE_FAUCET="faucet"

# A type of actor representing a participating node.
declare CCTL_ACCOUNT_TYPE_NODE="node"

# A type of actor representing a user.
declare CCTL_ACCOUNT_TYPE_USER="user"

# Base RPC server port number.
declare CCTL_BASE_PORT_RPC=11000

# Base JSON server port number.
declare CCTL_BASE_PORT_REST=14000

# Base event server port number.
declare CCTL_BASE_PORT_SSE=18000

# Base network server port number.
declare CCTL_BASE_PORT_NETWORK=22000

# Base speculative execution RPC server port number.
declare CCTL_BASE_PORT_SPEC_EXEC=25000

# cURL arguments which are used when talking to the CCTL nodes.
# We need to allow retires and limit the default timeouts because not all
# testing scenarios guarantee that nodes are responsive immediately, which may
# lead to the test being stuck. The exponential backoff delay used for reties
# is replaced with a constant 1 sec. delay.
# In addition, we don't want cURL to put anything on the standard output.
declare CCTL_CURL_ARGS_FOR_NODE_RELATED_QUERIES="--max-time 4 --connect-timeout 2 --retry 20 --retry-connrefused --retry-delay 1 -s"

# Default amount used when delegating.
declare CCTL_DEFAULT_AUCTION_DELEGATE_AMOUNT=1000000000000   # (1e12)

# Default era offset to apply when activating an upgrade.
declare CCTL_DEFAULT_ERA_ACTIVATION_OFFSET=2

# Default motes to pay for consumed gas.
declare CCTL_DEFAULT_GAS_PAYMENT=100000000000   # (1e11)

# Default amount used when making transfers.
declare CCTL_DEFAULT_TRANSFER_AMOUNT=2500000000   # (1e9)

# Intitial balance of faucet account.
declare CCTL_INITIAL_BALANCE_FAUCET=1000000000000000000000000000000000   # (1e33)

# Intitial balance of user account.
declare CCTL_INITIAL_BALANCE_USER=1000000000000000000000000000000000   # (1e33)

# Intitial balance of validator account.
declare CCTL_INITIAL_BALANCE_VALIDATOR=1000000000000000000000000000000000   # (1e33)

# Intitial delegation amount of a user account.
declare CCTL_INITIAL_DELEGATION_AMOUNT=1000000000000000000   # (1e18)

# Base weight applied to a validator at genesis.
declare CCTL_VALIDATOR_BASE_WEIGHT=1000000000000000000   # (1e18)

# Default amount used when submitting an auction bid.
declare CCTL_DEFAULT_AUCTION_BID_AMOUNT=1000000000000   # (1e12)

# Name of local cctl network.
declare CCTL_NET_NAME=cspr-dev-cctl

# Name of process group: boostrap validators.
declare CCTL_PROCESS_GROUP_1=validator-group-1

# Name of process group: genesis validators.
declare CCTL_PROCESS_GROUP_2=validator-group-2

# Name of process group: non-genesis validators.
declare CCTL_PROCESS_GROUP_3=validator-group-3

# Set of compiled smart contracts.
declare CCTL_SMART_CONTRACTS=(
    "activate_bid.wasm"
    "add_bid.wasm"
    "delegate.wasm"
    "named_purse_payment.wasm"
    "transfer_to_account_u512.wasm"
    "undelegate.wasm"
    "withdraw_bid.wasm"
)
