{inputs, ...}: let
  inherit (inputs) nixpkgs;

  mkNixos = system: host:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [./hosts/${host}];
      specialArgs = {inherit inputs;};
    };
  mkX86_64Nixos = mkNixos "x86_64-linux";
in {
  flake = {
    nixosConfigurations.Demeter = mkX86_64Nixos "Demeter";
    nixosConfigurations.Poseidon = mkX86_64Nixos "Poseidon";
    nixosConfigurations.Uranus = mkX86_64Nixos "Uranus";
    nixosConfigurations.Jupiter = mkX86_64Nixos "Jupiter";
  };
}
