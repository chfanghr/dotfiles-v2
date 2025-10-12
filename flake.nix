{
  description = "System configuration for Demeter";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/master";
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
    cardano-nix.url = "github:mlabs-haskell/cardano.nix";
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    agenix.url = "github:ryantm/agenix";
    hci-effects.url = "github:hercules-ci/hercules-ci-effects";
    hci-agent.url = "github:hercules-ci/hercules-ci-agent";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ucodenix.url = "github:e-tho/ucodenix";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    impermanence.url = "github:nix-community/impermanence";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
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
        ./configurations.nix
        ./dev-shells.nix
        ./hercules-ci.nix
        ./pre-commit.nix
      ];
    };
}
