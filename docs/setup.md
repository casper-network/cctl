# CCTL Setup

## Step 1: Verify Pre-requisites

- [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell))
- [cargo](https://doc.rust-lang.org/cargo/)
- [jq](https://jqlang.github.io/jq/)
- [make](https://www.gnu.org/software/make/)
- [python3](https://www.python.org/downloads/)

Plus the requirements to build [casper-node](https://github.com/CasperLabs/casper-node#pre-requisites-for-building)

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
