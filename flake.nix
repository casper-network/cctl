{
  description = "cctl - Bash application to work with a local casper-node network.";

  nixConfig = {
    extra-substituters = [
      "https://cspr.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cspr.cachix.org-1:vEZlmbOsmTXkmEi4DSdqNVyq25VPNpmSm6qCs4IuTgE="
    ];
  };

  inputs = {
    csprpkgs.url = "github:cspr-rad/csprpkgs";
    # We follow csprpkgs/nixpkgs because we want to avoid recompiling its packages
    # by injecting a different revision of nixpkgs. Most (and the largest)
    # of the runtime dependencies of cctl are from csprpkgs.
    nixpkgs.follows = "csprpkgs/nixpkgs";
    rust-overlay.follows = "csprpkgs/rust-overlay";
  };

  outputs = { self, nixpkgs, csprpkgs, rust-overlay }:
    let
      # eachSystem :: [ System ] -> (System -> FlakeOutputs)
      eachSystem = systems: f:
        let
          # Merge together the outputs for all systems.
          op = attrs: system:
            let
              ret = f system;
              op = attrs: key: attrs //
                {
                  ${key} = (attrs.${key} or { })
                    // { ${system} = ret.${key}; };
                }
              ;
            in
            builtins.foldl' op attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } systems;

      eachDefaultSystem = eachSystem [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      herculesCI.ciSystems = [ "x86_64-linux" "aarch64-linux" ];
      overlays.default = import ./overlay.nix;
    }
    // eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default csprpkgs.overlays.default rust-overlay.overlays.default ]; };
      in
      {
        packages = {
          inherit (pkgs) cctl cctl-test-utils;
          default = pkgs.cctl;
        };
        
        devsShells.cctl-test-utils = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.risc0package ];
        };

        formatter = pkgs.nixpkgs-fmt;

        checks.format = pkgs.runCommand "format-check" { buildInputs = [ pkgs.nixpkgs-fmt ]; } ''
          set -euo pipefail
          cd ${self}
          nixpkgs-fmt --check .
          touch $out
        '';
      });
}
