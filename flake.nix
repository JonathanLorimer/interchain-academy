{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
    rust-overlay.url = github:oxalica/rust-overlay;
    devshell.url = github:numtide/devshell;
    cosmos-nix.url = github:informalsystems/cosmos.nix;
  };

  outputs = {
    nixpkgs,
    flake-utils,
    rust-overlay,
    devshell,
    cosmos-nix,
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
      in {
        devShells.default = pkgs.devshell.mkShell {
          devshell = {
            name = "Interchain Academy";
            packages = with pkgs; [
              cosmos-nix.packages.${system}.simd
              # Rust build inputs
              pkg-config
              openssl

              # LSP's
              rust-analyzer
              rnix-lsp

              # Tools
              rust-toolchain
            ];
          };
        };
      });
}
