{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.dotfiles.shared.props.purposes.graphical.gaming {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      # obs-gstreamer
      wlrobs
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };
}
