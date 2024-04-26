final: prev: {
  cctl-test-utils = final.callPackage ./cctl-test-utils { };
  cctl = final.callPackage ./package.nix { };
}
