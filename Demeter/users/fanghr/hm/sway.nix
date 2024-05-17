{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4"; # Super key
      output = {
        "HDMI-A-1" = {
          mode = "2560x1440@120Hz";
          scale = "2";
        };
        "DP-1" = {
          mode = "3840x2160@120Hz";
          scale = "3";
        };
      };
    };
  };
}
