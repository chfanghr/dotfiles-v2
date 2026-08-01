{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
in
  mkIf config.dotfiles.shared.props.purposes.graphical.desktop {
    programs.noctalia = {
      enable = true;

      systemd.enable = true;

      settings = {
        theme = {
          mode = "auto";
          source = "builtin";
          builtin = "Noctalia";
          templates.builtin_ids = ["wezterm" "gtk3" "gtk4" "kcolorscheme" "niri" "qt"];
        };

        wallpaper = {
          enabled = true;
          default.path = ./assets/vlcsnap-2024-03-24-20h48m09s067.png;
        };

        shell = {
          shell.font_family = "3270 Nerd Font Mono";
          launch_apps_as_systemd_services = true;
          niri_overview_type_to_launch_enabled = true;
        };

        backdrop.enabled = true;

        idle = {
          behavior_order = ["lock"];
          behavior.lock = {
            action = "lock";
            enabled = true;
            timeout = 600.0;
          };
        };
      };
    };

    home.packages = [pkgs.qt6Packages.qt6ct];

    wayland.windowManager.niri = {
      enable = true;

      settings = {
        spawn-at-startup = "noctalia";

        environment.QT_QPA_PLATFORMTHEME = "qt6ct";

        debug.honor-xdg-activation-with-invalid-serial = {};

        binds = {
          "Mod+Space".spawn-sh = "noctalia msg panel-toggle launcher";
          "Mod+S".spawn-sh = "noctalia msg panel-toggle control-center";
          "Mod+Comma".spawn-sh = "noctalia msg settings-toggle";
          "Alt+Tab".spawn-sh = "noctalia msg window-switcher";
          "Super+Control+Q".spawn-sh = "noctalia msg session lock";

          "XF86AudioRaiseVolume".spawn-sh = "noctalia msg volume-up";
          "XF86AudioLowerVolume".spawn-sh = "noctalia msg volume-down";
          "XF86AudioMute".spawn-sh = "noctalia msg volume-mute";
          "XF86MonBrightnessUp".spawn-sh = "noctalia msg brightness-up";
          "XF86MonBrightnessDown".spawn-sh = "noctalia msg brightness-down";
        };

        blur = {
          passes = 2;
          offset = 3.0;
          noise = 0.03;
          saturation = 1.0;
        };

        switch-events.lid-close.spawn = [
          "noctalia"
          "msg"
          "session"
          "lock-and-suspend"
        ];

        _children = [
          {
            window-rule = {
              exclude._props.app-id = ''^(gamescope|steam_app_\\d+)$'';
              geometry-corner-radius = 20;
              clip-to-geometry = true;
            };
          }
          {
            window-rule._children = [
              {match._props.app-id = "dev.noctalia.Noctalia";}
              {open-floating = true;}
              {default-column-width.fixed = 1080;}
              {default-window-height.fixed = 920;}
            ];
          }
          {
            layer-rule._children = [
              {match._props.namespace = "^noctalia-backdrop";}
              {place-within-backdrop = true;}
            ];
          }
          {
            window-rule.background-effect = {
              blur = true;
              xray = false;
            };
          }
          {
            layer-rule._children = [
              {match._props.namespace = ''^noctalia-(bar-[^"]+|notification|dock|panel|attached-panel|osd)$'';}
              {background-effect.xray = false;}
            ];
          }
          {
            layer-rule._children = [
              {match._props.namespace = "noctalia-window-switcher";}
              {
                background-effect = {
                  blur = true;
                  xray = false;
                };
              }
            ];
          }
        ];
      };
    };
  }
