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
    nix = {
      builderPrivateKeyAgeSecret = mkOption {
        type = types.nullOr types.path;
        default = null;
      };

      builderPubKeys = mkOption {
        type = types.listOf types.str;
        default = [];
      };
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
            "https://om.cachix.org?priority=3"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "mlabs.cachix.org-1:gStKdEqNKcrlSQw5iMW6wFCj3+b+1ASpBVY2SYuNV2M="
            "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
            "chfanghr.cachix.org-1:gt1W4ZP4F/kgsA2JtH+di/yBaUM2WPMqr0IrRyIIED0="
            "om.cachix.org-1:ifal/RLZJKN4sbpScyPGqJ2+appCslzu7ZZF/C01f2Q="
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
            secretKeyFile = config.nix.settings.secret-key-files;
            openFirewall = true;
            package = pkgs.nix-serve-ng;
          };
        };
      }
    )
    (
      mkIf (nixRolesProps.builder && config.dotfiles.nixos.nix.builderPrivateKeyAgeSecret == null) {
        services.generate-nix-cache-key.enable = true;
      }
    )
    (
      mkIf (nixRolesProps.builder && config.dotfiles.nixos.nix.builderPrivateKeyAgeSecret != null) {
        age.secrets.nix-cache-key = {
          file = config.dotfiles.nixos.nix.builderPrivateKeyAgeSecret;
          owner = "root";
          group = "root";
          mode = "0400";
        };

        nix.settings.secret-key-files = config.age.secrets.nix-cache-key.path;
      }
    )
    (
      mkIf sharedProps.purposes.work {
        nix = {
          package = pkgs.nixVersions.nix_2_31;

          settings = {
            substituters = [
              # "https://mlabs.cachix.org?priority=3"
              # "https://chfanghr.cachix.org"
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
