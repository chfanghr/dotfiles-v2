{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nixpkgs;
  inherit (lib) nameValuePair;
  inherit (builtins) listToAttrs;

  mkNixos = system: host: let
    final = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [./hosts/${host}];
      specialArgs = {inherit inputs;};
    };
    hostName = final.config.networking.hostName;
  in
    nameValuePair hostName final;
  mkX86_64Nixos = mkNixos "x86_64-linux";

  nixosConfigurations = listToAttrs [
    (mkX86_64Nixos "Artemis")
    (mkX86_64Nixos "Athena")
    (mkX86_64Nixos "Demeter")
    (mkX86_64Nixos "Dionysus")
    (mkX86_64Nixos "Eros")
    (mkX86_64Nixos "Jupiter")
    (mkX86_64Nixos "Persephone")
    (mkX86_64Nixos "Poseidon")
    (mkX86_64Nixos "Uranus")
  ];
in {
  flake = {
    inherit nixosConfigurations;
  };
}
