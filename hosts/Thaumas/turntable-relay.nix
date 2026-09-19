{pkgs, ...}: {
  services.pipewire.systemWide = true;
  systemd.user.services.wireplumber.wantedBy = ["default.target"];
  users.users.fanghr = {
    linger = true;
    extraGroups = ["audio" "pipewire"];
  };

  environment.defaultPackages = [
    pkgs.cyme
  ];
}
