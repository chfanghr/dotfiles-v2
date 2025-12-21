{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
in
  mkIf config.dotfiles.shared.props.purposes.graphical.desktop
  {
    xdg.portal.enable = true;
    # xdg.portal.wlr.enable = mkDefault true;
    # xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-wlr];
    # xdg.portal.configPackages = [pkgs.xdg-desktop-portal-wlr];

    programs.hyprland = {
      enable = true;
    };

    fonts.packages = [pkgs.noto-fonts pkgs.hack-font];
    fonts.fontconfig.defaultFonts = {
      monospace = ["Hack" "Noto Sans Mono"];
      sansSerif = ["Noto Sans"];
      serif = ["Noto Serif"];
    };

    services.accounts-daemon.enable = true;

    programs.dconf.enable = true;

    programs.firefox = {
      enable = true;
      nativeMessagingHosts.packages = [
        pkgs.firefoxpwa
      ];
    };
    environment.systemPackages = [pkgs.firefoxpwa];

    services.gvfs.enable = true;

    qt.enable = true;

    services.libinput.enable = true;

    services.desktopManager.plasma6.enable = true;

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-rime
          fcitx5-pinyin-zhwiki
          kdePackages.fcitx5-with-addons
          kdePackages.fcitx5-chinese-addons
        ];
        waylandFrontend = true;
      };
    };

    programs.xwayland.enable = true;

    programs.kdeconnect.enable = true;

    programs.winbox = {
      enable = true;
      openFirewall = true;
      package = pkgs.winbox4;
    };
  }
