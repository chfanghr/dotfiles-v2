{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkMerge mkIf;
in {
  config = mkMerge [
    {
      environment.systemPackages = with pkgs; [
        curl
        coreutils
        file
      ];

      programs = {
        zsh = {
          enable = true;
          enableBashCompletion = true;
        };
        git.enable = true;
        neovim = {
          viAlias = true;
          vimAlias = true;
          defaultEditor = true;
        };
      };

      i18n.defaultLocale = "en_US.UTF-8";
    }
    (mkIf config.dotfiles.shared.props.networking.home.onLanNetwork {
      time.timeZone = "Asia/Hong_Kong";
    })
  ];
}
