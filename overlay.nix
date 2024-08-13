final: prev: {
  cctl = final.callPackage ./package.nix { casper-node = final.casper-node_2; };
}
