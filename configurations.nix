{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) deploy-rs;
  inherit
    (lib)
    nameValuePair
    warnIf
    map
    filter
    ;
  inherit (builtins) listToAttrs;

  nixpkgsDef = inputs.nixpkgs;

  specialArgs = {inherit inputs;};

  mkNixos = {
    hostname,
    nixpkgs ? nixpkgsDef,
    extraModules ? [],
    ...
  }: let
    nixos = nixpkgs.lib.nixosSystem {
      modules = extraModules ++ [./hosts/${hostname}];
      inherit specialArgs;
    };
  in
    warnIf (hostname != nixos.config.networking.hostName)
    "expected `networking.hostName` to be ${hostname}, but got ${nixos.config.networking.hostName}"
    nixos;

  mkNode = {
    nixos,
    fqdn,
    ...
  }: {
    hostname = fqdn;
    profiles.system = {
      sshUser = "fanghr";
      user = "root";
      path = deploy-rs.lib.x86_64-linux.activate.nixos nixos;
      interactiveSudo = true;
      fastConnection = true;
    };
  };

  mkNixosAndNode = {hostname, ...} @ cfg: let
    nixos = mkNixos cfg;
    node = mkNode (cfg // {inherit nixos;});
  in {
    name = hostname;
    kind = "nixos";
    inherit nixos node;
  };

  hosts = [
    (mkNixosAndNode {
      hostname = "Anemoi";
      fqdn = "anemoi.snow-dace.ts.net";
    })
    (mkNixosAndNode {
      hostname = "Apollo";
      fqdn = "apollo.snow-dace.ts.net";
    })
    (mkNixosAndNode {
      hostname = "Artemis";
      fqdn = "artemis.barbel-tritone.ts.net";
    })
    (mkNixosAndNode {
      hostname = "Athena";
      fqdn = "athena.snow-dace.ts.net";
    })
    (mkNixosAndNode {
      hostname = "Demeter";
      fqdn = "demeter.snow-dace.ts.net";
    })
    (mkNixosAndNode {
      hostname = "Dionysus";
      fqdn = "dionysus.snow-dace.ts.net";
    })
    (mkNixosAndNode {
      hostname = "Hestia";
      fqdn = "hestia.snow-dace.ts.net";
    })
    (mkNixosAndNode {
      hostname = "Jupiter";
      fqdn = "jupiter.snow-dace.ts.net";
      inherit (inputs.jovian.inputs) nixpkgs;
      extraModules = [{home-manager.users.fanghr.home.enableNixpkgsReleaseCheck = false;}];
    })
    (mkNixosAndNode {
      hostname = "Persephone";
      fqdn = "persephone.snow-dace.ts.net";
    })
    (mkNixosAndNode {
      hostname = "Poseidon";
      fqdn = "poseidon.snow-dace.ts.net";
    })
    (mkNixosAndNode {
      hostname = "Uranus";
      fqdn = "uranus.snow-dace.ts.net";
      inherit (inputs.jovian.inputs) nixpkgs;
      extraModules = [{home-manager.users.fanghr.home.enableNixpkgsReleaseCheck = false;}];
    })
    (mkNixosAndNode {
      hostname = "Telephus";
      fqdn = "telephus.snow-dace.ts.net";
    })
  ];

  nixosConfigurations = listToAttrs (
    map (h: nameValuePair h.name h.nixos) (filter (h: h.kind == "nixos") hosts)
  );

  deploy = {
    nodes = listToAttrs (map (h: nameValuePair h.name h.node) hosts);
  };
in {
  flake = {
    inherit nixosConfigurations deploy;
  };
}
