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
      };
    };
  };
}
