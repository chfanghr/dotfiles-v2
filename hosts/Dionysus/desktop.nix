{
  pkgs,
  lib,
  ...
}: {
  home-manager.users.fanghr = {
    wayland.windowManager.niri.settings = {
      environment = {
        NIXOS_OZONE_WL = "1";
      };

      _children = [
        {
          output = {
            _args = ["DP-3"];
            mode = "3840x2160@240.016";
            transform = "90";
            position._props = {
              x = 0;
              y = 0;
            };
            scale = 1.25;
          };
        }
        {
          output = {
            _args = ["DP-4"];
            mode = "3840x2160@240.016";
            focus-at-startup = {};
            position._props = {
              x = 1728;
              y = 672;
            };
            scale = 1.25;
            # variable-refresh-rate = {};
          };
        }
      ];
    };

    programs.noctalia.settings = {
      shell.avatar_path = "/home/fanghr/.face";
      location.auto_locate = true;

      bar.default = {
        background_opacity = 0.45;
        end = [
          "media"
          "tray"
          "notifications"
          "clipboard"
          "network"
          "bluetooth"
          "volume"
          "brightness"
          "control-center"
          "session"
          "screenshot"
        ];
        margin_ends = 0;
        scale = 1.2;
        thickness = 35;
      };
    };

    home.packages = [
      pkgs.gcr
      pkgs.handbrake
      pkgs.yacreader
      (pkgs.chromium.override {enableWideVine = true;})
      pkgs.thunderbird
    ];

    services = {
      kdeconnect.enable = true;
      gpg-agent.pinentry.package = lib.mkForce pkgs.pinentry-gnome3;
    };
  };

  services = {
    sunshine = {
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    desktopManager.gnome.enable = true;
  };
}
