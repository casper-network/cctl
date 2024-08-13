{ casper-client-rs
, casper-node
, casper-node-launcher
, casper-node-contracts
, casper-sidecar
, coreutils
, python3
, writeShellScriptBin
, symlinkJoin
, findutils
, less
, lsof
, jq
, runCommand
}:
let
  python = python3.withPackages (ps: with ps; [ supervisor tomlkit toml ]);
  cspr-bins = symlinkJoin {
    name = "cspr-bins";
    paths = [
      casper-client-rs
      casper-node
      casper-node-launcher
      casper-node-contracts
      casper-sidecar
    ];
  };
  casperResources = runCommand "casper-resources" { } ''
    create_symlinks() {
      local resource_dir="$1"
      local target_dir="$2"
      mkdir -p "$target_dir"
      for nested_dir in "$resource_dir"/*/; do
        echo $nested_dir
        if [ -d "$nested_dir" ]; then
          # Get the base name of the directory
          base_name=$(basename "$nested_dir")
          # Create a symlink in the target directory
          ln -s "$nested_dir" "$target_dir/$base_name"
        fi
      done
    }
    create_symlinks "${casper-node.src}/resources" "$out/casper-node"
    create_symlinks "${casper-sidecar.src}/resources" "$out/casper-sidecar"
  '';
  src = ./.;
  mkCctlCommand = commandName: commandPath: writeShellScriptBin "cctl-${commandName}" ''
    export CCTL=${src}
    export CCTL_ASSETS=''${CCTL_ASSETS:-./assets}
    export CSPR_PATH_TO_RESOURCES=${casperResources}
    export CSPR_PATH_TO_BIN=${cspr-bins}/bin
    ${builtins.readFile "${src}/cmds/${commandPath}.sh"}
  '';
in
symlinkJoin {
  name = "cctl";
  paths = [
    coreutils
    python
    findutils
    less
    lsof
    jq
    # Infrastructure Commands:
    # ... network
    (mkCctlCommand "infra-net-setup" "infra/net/ctl_setup")
    (mkCctlCommand "infra-net-start" "infra/net/ctl_start")
    (mkCctlCommand "infra-net-status" "infra/net/view_status")
    (mkCctlCommand "infra-net-stop" "infra/net/ctl_stop")
    (mkCctlCommand "infra-net-teardown" "infra/net/ctl_teardown")
    (mkCctlCommand "infra-net-view-paths" "infra/net/view_paths")
    (mkCctlCommand "infra-net-view-status" "infra/net/view_status")

    # ... node control
    (mkCctlCommand "infra-node-clean" "infra/node/ctl_clean")
    (mkCctlCommand "infra-node-restart" "infra/node/ctl_restart")
    (mkCctlCommand "infra-node-start" "infra/node/ctl_start")
    (mkCctlCommand "infra-node-stop" "infra/node/ctl_stop")

    # ... node views
    (mkCctlCommand "infra-node-view-config" "infra/node/view_config")
    (mkCctlCommand "infra-node-view-error-log" "infra/node/view_log_stderr")
    (mkCctlCommand "infra-node-view-log" "infra/node/view_log_stdout")
    (mkCctlCommand "infra-node-view-metrics" "infra/node/view_metrics")
    (mkCctlCommand "infra-node-view-peers" "infra/node/view_peers")
    (mkCctlCommand "infra-node-view-peer-count" "infra/node/view_peer_count")
    (mkCctlCommand "infra-node-view-paths" "infra/node/view_paths")
    (mkCctlCommand "infra-node-view-ports" "infra/node/view_ports")
    (mkCctlCommand "infra-node-view-reactor-state" "infra/node/view_reactor_state")
    (mkCctlCommand "infra-node-view-status" "infra/node/view_status")
    (mkCctlCommand "infra-node-view-storage" "infra/node/view_storage")

    # ... sidecar control
    (mkCctlCommand "infra-sidecar-start" "infra/sidecar/ctl_start")
    (mkCctlCommand "infra-sidecar-stop" "infra/sidecar/ctl_stop")
    (mkCctlCommand "infra-sidecar-clean" "infra/sidecar/ctl_clean")

    # ... sidecar views
    (mkCctlCommand "infra-sidecar-view-config" "infra/sidecar/view_config")
    (mkCctlCommand "infra-sidecar-view-error-log" "infra/sidecar/view_log_stderr")
    (mkCctlCommand "infra-sidecar-view-log" "infra/sidecar/view_log_stdout")
    (mkCctlCommand "infra-sidecar-view-paths" "infra/sidecar/view_paths")
    (mkCctlCommand "infra-sidecar-view-ports" "infra/sidecar/view_ports")
    (mkCctlCommand "infra-sidecar-view-rpc-endpoint" "infra/sidecar/view_rpc_endpoint")
    (mkCctlCommand "infra-sidecar-view-rpc-schema" "infra/sidecar/view_rpc_schema")
    (mkCctlCommand "infra-sidecar-write-rpc-schema" "infra/sidecar/write_rpc_schema")

    # Chain commands:
    # ... awaiting
    (mkCctlCommand "chain-await-n-blocks" "chain/await/n_blocks")
    (mkCctlCommand "chain-await-n-eras" "chain/await/n_eras")
    (mkCctlCommand "chain-await-until-block-n" "chain/await/until_block_n")
    (mkCctlCommand "chain-await-until-era-n" "chain/await/until_era_n")

    # ... views
    (mkCctlCommand "chain-view-account" "chain/query/view_account")
    (mkCctlCommand "chain-view-account-of-faucet" "chain/query/view_account_of_faucet")
    (mkCctlCommand "chain-view-account-of-user" "chain/query/view_account_of_user")
    (mkCctlCommand "chain-view-account-of-validator" "chain/query/view_account_of_validator")
    (mkCctlCommand "chain-view-auction-info" "chain/query/view_auction_info")
    (mkCctlCommand "chain-view-block" "chain/query/view_block")
    (mkCctlCommand "chain-view-block-transfers" "chain/query/view_block_transfers")
    (mkCctlCommand "chain-view-era" "chain/query/view_era")
    (mkCctlCommand "chain-view-era-summary" "chain/query/view_era_summary")
    (mkCctlCommand "chain-view-genesis-accounts" "chain/query/view_genesis_accounts")
    (mkCctlCommand "chain-view-genesis-chainspec" "chain/query/view_genesis_chainspec")
    (mkCctlCommand "chain-view-height" "chain/query/view_height")
    (mkCctlCommand "chain-view-last-finalized-block" "chain/query/view_last_finalized_block")
    (mkCctlCommand "chain-view-state-root-hash" "chain/query/view_state_root_hash")
    (mkCctlCommand "chain-view-view-tx" "chain/query/view_tx")
    (mkCctlCommand "chain-view-view-tip-info" "chain/query/view_tip_info")
    (mkCctlCommand "chain-view-view-validator-changes" "chain/query/view_validator_changes")

    # Transaction commands:
    # ... system auction
    (mkCctlCommand "tx-auction-activate-bid" "tx/auction/activate_bid")
    (mkCctlCommand "tx-auction-delegate" "tx/auction/delegate")
    (mkCctlCommand "tx-auction-add-bid" "tx/auction/add_bid")
    (mkCctlCommand "tx-auction-undelegate" "tx/auction/undelegate")
    (mkCctlCommand "tx-auction-withdraw-bid" "tx/auction/withdraw_bid")

    # ... system mint
    (mkCctlCommand "tx-mint-dispatch-transfer" "tx/mint/dispatch_transfer")
    (mkCctlCommand "tx-mint-dispatch-transfer-batch" "tx/mint/dispatch_transfer_batch")
    (mkCctlCommand "tx-mint-write-transfer-batch" "tx/mint/write_transfer_batch")
  ];
}
