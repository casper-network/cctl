#!/bin/bash
cd /
rm casper-node/target/release/*.rlib
rm -rf casper-node/target/release/build
rm -rf casper-node/target/release/deps
rm -rf casper-node/target/release/.fingerprint
rm -rf casper-node/target/wasm32-unknown-unknown/release/build
rm -rf casper-node/target/wasm32-unknown-unknown/release/deps
rm -rf casper-node/target/wasm32-unknown-unknown/release/.fingerprint
rm -rf casper-node-launcher/target/release/build
rm -rf casper-node-launcher/target/release/deps
rm -rf casper-node-launcher/target/release/.fingerprint
rm -rf casper-client-rs/target/release/build
rm -rf casper-client-rs/target/release/deps
rm -rf casper-client-rs/target/release/.fingerprint
rm -rf casper-node/.git
rm -rf casper-client-rs/.git
rm -rf casper-node-launcher/.git
rm -rf cctl/.git
rm -rf casper-node/utils/nctl
rm -rf casper-node/utils/nctl-metrics
