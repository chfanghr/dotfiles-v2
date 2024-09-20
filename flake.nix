{
  description = "System configuration for Demeter";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-nvim = {
      url = "github:chfanghr/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.follows = "my-nvim/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    cardano-nix.url = "github:mlabs-haskell/cardano.nix/szg251/conway";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    disko.url = "github:nix-community/disko";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    agenix.url = "github:ryantm/agenix";
    hci-effects.url = "github:hercules-ci/hercules-ci-effects";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      imports = [
        ./flake-part-modules.nix
        ./hercules-ci.nix
        ./pre-commit.nix
      ];
    };
}
