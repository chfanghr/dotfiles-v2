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
        modules = [(import ./Demeter)];
        specialArgs = {inherit inputs;};
      };
  };
}
