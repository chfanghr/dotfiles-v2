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
  };

  outputs = {
    nixpkgs,
    home-manager,
    vscode-server,
    ...
  }: let
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
          ./cs2.nix
          ./generate-nix-cache-key.nix
          ./traefik.nix
          ./grafana.nix
          ./prometheus.nix
          vscode-server.nixosModules.default
          {
            environment.systemPackages = [
              home-manager.packages."${system}".home-manager
            ];
            services.vscode-server.enable = true;
          }
          ./thungghuan.nix
        ];
        specialArgs = {
          inherit hostname;
        };
      };
    };
  };
}
