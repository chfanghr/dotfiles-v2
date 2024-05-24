{
  lib,
  config,
  ...
}:
lib.mkIf (config.dotfiles.hasProp "is-for-gaming") {
  hardware = {
    xone.enable = true;
    steam-hardware.enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  networking = {
    useNetworkd = false;
    networkmanager = {
      enable = true;
      insertNameservers = ["8.8.8.8" "1.1.1.1" "114.114.114.114"];
    };
  };
}
