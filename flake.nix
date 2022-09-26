{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
    rust-overlay.url = github:oxalica/rust-overlay;
    devshell.url = github:numtide/devshell;
    cosmos-nix.url = github:informalsystems/cosmos.nix;
    cosmos-nix.inputs.nixpkgs.follows = "nixpkgs";
    # ignite-cli-src.flake = false;
    # ignite-cli-src.url = github:ignite/cli/v0.24.0;
  };

  outputs = {
    nixpkgs,
    flake-utils,
    rust-overlay,
    devshell,
    cosmos-nix,
    # ignite-cli-src,
    self,
  }:
    with flake-utils.lib;
      eachDefaultSystem (system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
            devshell.overlay
          ];
        };
        rust-toolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
        # ignite-cli = pkgs.buildGoModule rec {
        #         name = "ignite-cli";
        #         src = ignite-cli-src;
        #         vendorSha256 = "sha256-P1NYgvdobi6qy1sSKFwkBwPRpLuvCJE5rCD2s/vvm14=";
        #         doCheck = false;
        #         ldflags = ''
        #           -X github.com/ignite/cli/ignite/version.Head=${src.rev}
        #           -X github.com/ignite/cli/ignite/version.Version=v0.24.0
        #           -X github.com/ignite/cli/ignite/version.Date=${builtins.toString (src.lastModified)}
        #         '';
        #       };
      in {
        devShells.default = pkgs.devshell.mkShell {
          commands = [
            {
              help = "Simulate a cosmos sdk chain using the simapp binary";
              package = cosmos-nix.packages.${system}.simd;
              category = "chain tools";
            }
            {
              help = "Cli for generating sdk components";
              package = cosmos-nix.packages.${system}.ignite-cli;
              name = "ignite";
              category = "development tools";
            }
          ];
          devshell = {
            name = "Interchain Academy";
            packages = with pkgs; [
              # Chain tools
              cosmos-nix.packages.${system}.simd

              # Rust build inputs
              pkg-config
              openssl

              # LSP's
              rust-analyzer
              rnix-lsp

              # Tools
              rust-toolchain
              go
              nodejs-18_x
            ];
          };
        };
      });
}
