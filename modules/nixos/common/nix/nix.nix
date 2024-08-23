{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkMerge mkIf types mdDoc mkOption;

  mkPropOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "NixOS Property: this machine ${name}";
    };

  nixRolesProps = config.dotfiles.nixos.props.nix.roles;
  sharedProps = config.dotfiles.shared.props;
in {
  options.dotfiles.nixos = {
    props.nix.roles = {
      builder = mkPropOption "builds nix derivations for other machines";
      consumer = mkPropOption "consumes nix derivations built by builders";
    };
    nix.builderPubKeys = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

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
            "mlabs.cachix.org-1:gStKdEqNKcrlSQw5iMW6wFCj3+b+1ASpBVY2SYuNV2M="
            "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
          ];
        };
        gc.automatic = true;
      };
    }
    (
      mkIf nixRolesProps.builder {
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
      mkIf sharedProps.purposes.work {
        nix = {
          package = pkgs.nixVersions.nix_2_23;

          settings = {
            substituters = [
              "https://mlabs.cachix.org?priority=3"
              # "https://iohk.cachix.org?priority=999"
            ];
          };
        };
      }
    )
    (
      mkIf nixRolesProps.consumer {
        nix.settings.trusted-public-keys = config.dotfiles.nixos.nix.builderPubKeys;
      }
    )
  ];
}
