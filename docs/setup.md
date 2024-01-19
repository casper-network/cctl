# CCTL Setup

## Step 1: Verify Pre-requisites

1. bash shell.
2. python3.  

## Step 2: Setup System

```
# Install python dependencies.
python3 -m pip install supervisor toml tomlkit

# Clone repos.
cd YOUR_WORKING_DIRECTORY
git clone https://github.com/casper-network/casper-node.git
git clone https://github.com/casper-network/casper-node-launcher.git
git clone https://github.com/casper-network/casper-client.git
git clone https://github.com/casper-network/cctl.git

# Install rust toolchain.
cd ./casper-node
make setup-rs
```

## Step 3: Extend .bashrc file (optional)

```
cd YOUR_WORKING_DIRECTORY/cctl

cat >> $HOME/.bashrc <<- EOM

# ----------------------------------------------------------------------
# CASPER - CCTL
# ----------------------------------------------------------------------

# Activate CCTL shell.
. $(pwd)/activate

EOM
```

**NOTE** - if you do not wish to extend your .bashrc file then you will need to activate cctl in each terminal session.
