{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkDefault mkOption types;

  inherit (config.dotfiles.nixos.users) superUser;
in {
  options.dotfiles.nixos.users.superUser = mkOption {
    type = types.str;
    default = "fanghr";
    readOnly = true;
  };

  config = {
    assertions = [
      {
        assertion = config.users.users.${superUser}.hashedPassword != null;
        message = "Password of ${superUser} is not set";
      }
    ];

    users.users.${superUser} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
      ];
      shell = pkgs.zsh;
      home = "/home/${superUser}";
      createHome = true;
    };

    programs.zsh.enable = mkDefault true;

    home-manager.users.${superUser} = {
      imports = [(import ../../../home-manager/${superUser})];

      dotfiles.shared = config.dotfiles.shared;
    };
  };
}
