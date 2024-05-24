{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkMerge mkIf;
  inherit (config.dotfiles) hasProp;
in {
  imports = [
    ./generate-nix-cache-key.nix
  ];

  config = mkMerge [
    {
      nix = {
        extraOptions = ''
          experimental-features = nix-command flakes ca-derivations
          keep-outputs = true
          keep-derivations = true
        '';
        settings = {
          trusted-users = [
            "root"
          ];
          substituters = [
            "https://nix-community.cachix.org?priority=2"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
      };
    }
    (
      mkIf (hasProp "is-nix-builder") {
        services = {
          nix-serve = {
            enable = true;
            secretKeyFile = config.services.generate-nix-cache-key.privateKeyPath;
            openFirewall = true;
            package = pkgs.nix-serve-ng;
          };

          generate-nix-cache-key.enable = true;
        };
      }
    )
    (
      mkIf (hasProp "is-for-work") {
        nix = {
          package = pkgs.nixVersions.nix_2_21;

          settings = {
            substituters = [
              "https://mlabs.cachix.org?priority=3"
              "https://iohk.cachix.org?priority=999"
            ];
            trusted-public-keys = [
              "mlabs.cachix.org-1:gStKdEqNKcrlSQw5iMW6wFCj3+b+1ASpBVY2SYuNV2M="
              "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
            ];
          };
        };
      }
    )
    (
      mkIf (hasProp "is-nix-consumer") {
        nix.settings.trusted-public-keys = config.dotfiles.nix.buildMachinePulicKeys;
      }
    )
  ];
}
