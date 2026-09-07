{pkgs, ...}: {
  programs.steam.protontricks.enable = true;

  home-manager.users.fanghr.home.packages = [pkgs.boxflat];

  services.udev.packages = [pkgs.boxflat];
}
