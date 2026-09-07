{pkgs, ...}: {
  home-manager.users.fanghr = {
    wayland.windowManager.niri.settings = {
      binds = {
        "Mod+F".fullscreen-window = {};
        "Mod+WheelScrollDown".focus-workspace-down = {};
        "Mod+WheelScrollUp".focus-workspace-up = {};
        "Mod+WheelScrollLeft" = {
          _props.cooldown-ms = 256;
          focus-column-left = {};
        };
        "Mod+WheelScrollRight" = {
          _props.cooldown-ms = 256;
          focus-column-right = {};
        };
        "Mod+Shift+Right".move-window-to-monitor-right = {};
        "Mod+Shift+Left".move-window-to-monitor-left = {};
        "Mod+Alt+Right".move-column-right-or-to-monitor-right = {};
        "Mod+Alt+Left".move-column-left-or-to-monitor-left = {};
        "Mod+Shift+M".maximize-window-to-edges = {};
        "Mod+Shift+5".screenshot = {};
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

    home.packages = [
      pkgs.handbrake
      pkgs.yacreader
      (pkgs.chromium.override {enableWideVine = true;})
    ];

    services.kdeconnect.enable = true;
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
