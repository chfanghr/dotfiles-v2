{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nixpkgs deploy-rs;
  inherit (lib) nameValuePair warnIf map filter;
  inherit (builtins) listToAttrs;

  specialArgs = {inherit inputs;};

  mkNixos = hostname: let
    nixos = nixpkgs.lib.nixosSystem {
      modules = [./hosts/${hostname}];
      inherit specialArgs;
    };
  in
    warnIf (hostname != nixos.config.networking.hostName)
    "expected `networking.hostName` to be ${hostname}, but got ${nixos.config.networking.hostName}"
    nixos;

  mkNode = nixos: fqdn: {
    hostname = fqdn;
    profiles.system = {
      sshUser = "fanghr";
      user = "root";
      path = deploy-rs.lib.x86_64-linux.activate.nixos nixos;
      interactiveSudo = true;
      fastConnection = true;
    };
  };

  mkNixosAndNode = hostname: fqdn: let
    nixos = mkNixos hostname;
    node = mkNode nixos fqdn;
  in {
    name = hostname;
    kind = "nixos";
    inherit nixos node;
  };

  hosts = [
    (mkNixosAndNode "Apollo" "apollo.snow-dace.ts.net")
    (mkNixosAndNode "Artemis" "artemis.barbel-tritone.ts.net")
    (mkNixosAndNode "Athena" "athena.snow-dace.ts.net")
    (mkNixosAndNode "Demeter" "demeter.snow-dace.ts.net")
    (mkNixosAndNode "Dionysus" "dionysus.snow-dace.ts.net")
    (mkNixosAndNode "Hestia" "hestia.snow-dace.ts.net")
    (mkNixosAndNode "Jupiter" "jupiter.snow-dace.ts.net")
    (mkNixosAndNode "Persephone" "persephone.snow-dace.ts.net")
    (mkNixosAndNode "Poseidon" "poseidon.snow-dace.ts.net")
    (mkNixosAndNode "Uranus" "uranus.snow-dace.ts.net")
  ];

  nixosConfigurations = listToAttrs (
    map (h: nameValuePair h.name h.nixos) (filter (h: h.kind == "nixos") hosts)
  );

  deploy = {nodes = listToAttrs (map (h: nameValuePair h.name h.node) hosts);};
in {
  flake = {
    inherit nixosConfigurations deploy;
  };
}
