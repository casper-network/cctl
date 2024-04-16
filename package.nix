{ casper-client-rs
, casper-node
, casper-node-launcher
, casper-node-contracts
, coreutils
, python3
, writeShellScriptBin
, symlinkJoin
, findutils
, less
, lsof
, jq
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
    ];
  };
  src = ./.;
  mkCctlCommand = commandName: commandPath: writeShellScriptBin "cctl-${commandName}" ''
    export CCTL=${src}
    export CCTL_ASSETS=''${CCTL_ASSETS:-./assets}
    export CSPR_PATH_TO_RESOURCES=${casper-node.src}/resources
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
    (mkCctlCommand "infra-net-setup" "infra/net/setup")
    (mkCctlCommand "infra-net-start" "infra/net/start")
    (mkCctlCommand "infra-net-status" "infra/net/status")
    (mkCctlCommand "infra-net-stop" "infra/net/stop")
    (mkCctlCommand "infra-net-teardown" "infra/net/teardown")
    (mkCctlCommand "infra-net-view-paths" "infra/net/view_paths")

    # ... node control
    (mkCctlCommand "infra-node-clean" "infra/node/clean")
    (mkCctlCommand "infra-node-stop" "infra/node/stop")
    (mkCctlCommand "infra-node-restart" "infra/node/restart")

    # ... node views
    (mkCctlCommand "infra-node-view-config" "infra/node/view_config")
    (mkCctlCommand "infra-node-view-error-log" "infra/node/view_log_stderr")
    (mkCctlCommand "infra-node-view-log" "infra/node/view_log_stdout")
    (mkCctlCommand "infra-node-view-metrics" "infra/node/view_metrics")
    (mkCctlCommand "infra-node-view-peers" "infra/node/view_peers")
    (mkCctlCommand "infra-node-view-peer-count" "infra/node/view_peer_count")
    (mkCctlCommand "infra-node-view-paths" "infra/node/view_paths")
    (mkCctlCommand "infra-node-view-ports" "infra/node/view_ports")
    (mkCctlCommand "infra-node-view-rpc-endpoint" "infra/node/view_rpc_endpoint")
    (mkCctlCommand "infra-node-view-rpc-schema" "infra/node/view_rpc_schema")
    (mkCctlCommand "infra-node-view-status" "infra/node/view_status")
    (mkCctlCommand "infra-node-view-storage" "infra/node/view_storage")
    (mkCctlCommand "infra-node-write-rpc-schema" "infra/node/write_rpc_schema")

    # Chain commands:
    # ... awaiting
    (mkCctlCommand "chain-await-n-blocks" "chain/await/n_blocks")
    (mkCctlCommand "chain-await-n-eras" "chain/await/n_eras")
    (mkCctlCommand "chain-await-until-block-n" "chain/await/until_block_n")
    (mkCctlCommand "chain-await-until-era-n" "chain/await/until_era_n")

    # ... views
    (mkCctlCommand "chain-view-account" "chain/query/view_account")
    (mkCctlCommand "chain-view-account-address" "chain/query/view_account_address")
    (mkCctlCommand "chain-view-account-balance" "chain/query/view_account_balance")
    (mkCctlCommand "chain-view-account-balances" "chain/query/view_account_balances")
    (mkCctlCommand "chain-view-account-of-faucet" "chain/query/view_account_of_faucet")
    (mkCctlCommand "chain-view-account-of-user" "chain/query/view_account_of_user")
    (mkCctlCommand "chain-view-account-of-validator" "chain/query/view_account_of_validator")
    (mkCctlCommand "chain-view-auction-info" "chain/query/view_auction_info")
    (mkCctlCommand "chain-view-block" "chain/query/view_block")
    (mkCctlCommand "chain-view-block-transfers" "chain/query/view_block_transfers")
    (mkCctlCommand "chain-view-deploy" "chain/query/view_deploy")
    (mkCctlCommand "chain-view-era" "chain/query/view_era")
    (mkCctlCommand "chain-view-era-summary" "chain/query/view_era_summary")
    (mkCctlCommand "chain-view-genesis-accounts" "chain/query/view_genesis_accounts")
    (mkCctlCommand "chain-view-genesis-chainspec" "chain/query/view_genesis_chainspec")
    (mkCctlCommand "chain-view-height" "chain/query/view_height")
    (mkCctlCommand "chain-view-last-finalized-block" "chain/query/view_last_finalized_block")
    (mkCctlCommand "chain-view-state-root-hash" "chain/query/view_state_root_hash")
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
