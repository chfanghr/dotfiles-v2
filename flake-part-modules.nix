{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nixpkgs;
  inherit (lib) recursiveUpdate foldl nameValuePair attrsToList;
  inherit (builtins) listToAttrs map;

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
    (mkX86_64Nixos "Demeter")
    (mkX86_64Nixos "Poseidon")
    (mkX86_64Nixos "Uranus")
    (mkX86_64Nixos "Jupiter")
    (mkX86_64Nixos "Artemis")
    (mkX86_64Nixos "Athena")
    (mkX86_64Nixos "Persephone")
    (mkX86_64Nixos "Dionysus")
    (mkX86_64Nixos "Oizys")
  ];

  mergeAttrs = foldl recursiveUpdate {};

  githubActions = inputs.nix-github-actions.lib.mkGithubMatrix (
    mergeAttrs (map ({
        name,
        value,
      }: {
        checks.${value.config.nixpkgs.system}.${name} = value.config.system.build.toplevel;
      })
      (attrsToList nixosConfigurations))
  );
in {
  flake = {
    inherit nixosConfigurations githubActions;
  };
}
