{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nixpkgs deploy-rs;
  inherit (lib) nameValuePair;
  inherit (builtins) listToAttrs;

  mkNixos = system: host: let
    final = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [./hosts/${host}];
      specialArgs = {inherit inputs;};
    };
  in
    nameValuePair host final;
  mkX86_64Nixos = mkNixos "x86_64-linux";

  nixosConfigurations = listToAttrs [
    (mkX86_64Nixos "Artemis")
    (mkX86_64Nixos "Athena")
    (mkX86_64Nixos "Demeter")
    (mkX86_64Nixos "Dionysus")
    (mkX86_64Nixos "Eros")
    (mkX86_64Nixos "Hestia")
    # (mkX86_64Nixos "Jupiter")
    (mkX86_64Nixos "Persephone")
    (mkX86_64Nixos "Poseidon")
    # (mkX86_64Nixos "Uranus")
  ];

  mkX86_64NixosDeployRsNode = host: fqdn: let
    final = {
      hsotname = fqdn;
      profiles.system = {
        sshUser = "fanghr";
        path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations.${host};
        interactiveSudo = true;
        fastConnection = true;
      };
    };
  in
    nameValuePair host final;

  nodes = listToAttrs [
    (mkX86_64NixosDeployRsNode "Artemis" "artemis.barbel-tritone.ts.net ")
    (mkX86_64NixosDeployRsNode "Athena" "athena.snow-dace.ts.net")
    (mkX86_64NixosDeployRsNode "Demeter" "demeter.snow-dace.ts.net")
    (mkX86_64NixosDeployRsNode "Dionysus" "dionysus.snow-dace.ts.net")
    (mkX86_64NixosDeployRsNode "Eros" "eros.snow-dace.ts.net")
    (mkX86_64NixosDeployRsNode "Hestia" "hestia.snow-dace.ts.net")
    # (mkX86_64NixosDeployRsNode "Jupiter" "jupiter.snow-dace.ts.net")
    (mkX86_64NixosDeployRsNode "Persephone" "persephone.snow-dace.ts.net")
    (mkX86_64NixosDeployRsNode "Poseidon" "poseidon.snow-dace.ts.net")
    # (mkX86_64NixosDeployRsNode "Uranus" "uranus.snow-dace.ts.net")
  ];
in {
  flake = {
    inherit nixosConfigurations;

    deploy = {inherit nodes;};
  };
}
