{inputs, ...}: let
  inherit (inputs) nixpkgs;
in {
  flake = {
    nixosConfigurations.Demeter = let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
      nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [(import ./hosts/Demeter)];
        specialArgs = {inherit inputs;};
      };
    nixosConfigurations.Poseidon = let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
      nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [(import ./hosts/Poseidon.nix)];
        specialArgs = {inherit inputs;};
      };
  };
}
