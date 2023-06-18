{
  description = "System configuration for Demeter";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    hostname = "Demeter";
  in {
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        inherit system;
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
        ];
        specialArgs = {
          inherit hostname;
        };
      };
    };
  };
}
