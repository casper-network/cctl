# CCTL Usage

## Step 0: Activate CCTL

To activate the cctl shell application:

```bash copy
. ./YOUR_WORKING_DIRECTORY/cctl/activate
```

To view full set of commands:  

```bash copy
cctl-[TAB]
```

To view commands to start, stop, & set up a network:

```bash copy
cctl-infra-net-[TAB]
```

To view commands to control or query with a node:

```bash copy
cctl-infra-node-[TAB]
```

To view commands to compile network binaries:

```bash copy
cctl-infra-bin-[TAB]
```

To view commands to await progression of chain:

```bash copy
cctl-chain-await-[TAB]
```

To view commands to view chain state:

```bash copy
cctl-chain-view-[TAB]
```

To view commands to send transactions into the network:

```bash copy
cctl-tx-[TAB]
```

To view help text for a command, type command name followed by help. For example:

```bash copy
cctl-infra-bin-compile help
```

## Step 1: Compile network binaries

Prior to testing a network ensure that the binary set is available:

```bash copy
cctl-infra-bin-compile mode=[debug|release]
```

## Step 2: Setup network

Upon successful compilation of binaries one can proceed to setting up the assets required to run a local network with a set of pre-funded test accounts.  The assets are copied to `$CCTL/assets`, where $CCTL is the cctl home directory.  

```bash copy
cctl-infra-net-setup
```

- The contents of `$CCTL/assets`:

```
/accounts
/bin
/daemon
/genesis
/nodes
```

- The contents of `$CCTL/assets/accounts`:

```
/faucet
/users
/validators
```

- The contents of `$CCTL/assets/nodes/node-X`:

```
/bin
/config
/keys
/logs
/storage
```

## Step 3: Start network

To setup & start a network type following commands:

```bash copy
cctl-infra-net-setup && cctl-infra-net-start
```

- To view process status of all nodes:

```bash copy
cctl-infra-net-status
```

NOTE - when viewing network status then you should observe 10 nodes, of which 5 will be running and 5 idle. 

## Step 4: View chain state

You can view chain state using the set of `cctl-chain-view-*` commands.  For example:

```bash copy
# View chain state.
cctl-chain-view-auction-info
cctl-chain-view-block
cctl-chain-view-era
cctl-chain-view-era-summary
cctl-chain-view-height
cctl-chain-view-last-finalized-block
cctl-chain-view-state-root-hash

# View test accounts.
cctl-chain-view-account-of-faucet
cctl-chain-view-account-of-user
cctl-chain-view-account-of-validator

# View genesis assets.
cctl-chain-view-genesis-accounts
cctl-chain-view-genesis-chainspec
```

## Step 5: Teardown network

To teardown a network once a dev/test session is complete:

```bash copy
cctl-infra-net-teardown
```

## Summary

Using CCTL one can spin up a local test network.  The CCTL commands parameter defaults are set for the general use case of testing a single local 5 node network.  You are encouraged to integrate CCTL into your daily workflow to standardize the manner in which the network is tested in a localized setting.
