{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkDefault mkOption types mkMerge mkIf;

  props = config.dotfiles.nixos.props.users;
in {
  options.dotfiles.nixos.props.users = {
    superUser = mkOption {
      type = types.str;
      default = "fanghr";
      readOnly = true;
    };
    fanghr.disableHm = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = config.users.users.${props.superUser}.hashedPassword != null;
          message = "Password of ${props.superUser} is not set";
        }
      ];

      users.users.${props.superUser} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "docker"
        ];
        shell = pkgs.zsh;
        home = "/home/${props.superUser}";
        createHome = true;
      };

      programs.zsh.enable = mkDefault true;
    }
    (
      mkIf (!props.fanghr.disableHm) {
        home-manager.users.${props.superUser} = {
          imports = [(import ../../../home-manager/${props.superUser})];

          dotfiles.shared = config.dotfiles.shared;
        };
      }
    )
  ];
}
