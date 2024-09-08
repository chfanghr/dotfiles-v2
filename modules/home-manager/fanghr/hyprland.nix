{
  pkgs,
  lib,
  config,
  ...
}: {
  options.dotfiles.hm.graphical.desktop.hyprland.extraConfig = lib.mkOption {
    type = lib.types.str;
    default = "";
  };
  config = lib.mkIf config.dotfiles.shared.props.purposes.graphical.desktop {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      plugins = [
        pkgs.hyprlandPlugins.hyprbars
      ];
      extraConfig = ''
        ${(builtins.readFile ./hyprland.conf)}
        ${config.dotfiles.hm.graphical.desktop.hyprland.extraConfig}
      '';
      systemd = {
        enableXdgAutostart = true;
        enable = true;
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };

      font = {
        name = "Sans";
        size = 11;
      };
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        preload = "${./assets/vlcsnap-2024-03-24-20h48m09s067.png}";
        wallpaper = ",${./assets/vlcsnap-2024-03-24-20h48m09s067.png}";
        splash = false;
      };
    };

    services.mako = {
      enable = true;
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };

    home.packages = with pkgs; [
      cantarell-fonts
      nerdfonts
      font-awesome
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif

      vlc
      telegram-desktop

      nemo-with-extensions
      wofi
      lxqt.lxqt-policykit
    ];
  };
}
