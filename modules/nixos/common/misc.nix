{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  programs.nix-index-database.comma.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    coreutils
    file
    rsync
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

  time.timeZone = mkDefault config.dotfiles.shared.props.location.timeZone;
}
