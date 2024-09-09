final: prev: {
  cctl = final.callPackage ./package.nix {
    casper-node = final.casper-node_2;
    casper-client-rs = final.casper-client-rs_2;
  };
}
