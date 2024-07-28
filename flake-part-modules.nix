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
    nixosConfigurations = {
      Demeter = mkX86_64Nixos "Demeter";
      Poseidon = mkX86_64Nixos "Poseidon";
      Uranus = mkX86_64Nixos "Uranus";
      Jupiter = mkX86_64Nixos "Jupiter";
      Artemis = mkX86_64Nixos "Artemis";
      Athena = mkX86_64Nixos "Athena";
    };
  };
}
