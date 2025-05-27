{
  lib,
  config,
  ...
}:
lib.mkIf config.dotfiles.shared.props.purposes.graphical.gaming {
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      full = true;
      no_display = true;
      cpu_load_change = true;
      toggle_hud = "Shift_R+F12";
    };
  };
}
