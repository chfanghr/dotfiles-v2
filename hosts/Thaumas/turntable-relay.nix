{pkgs, ...}: {
  services.pipewire.systemWide = true;
  systemd.user.services.wireplumber.wantedBy = ["default.target"];
  users.users.fanghr = {
    linger = true;
    extraGroups = ["audio" "pipewire"];
  };

  hardware.raspberry-pi."4".i2c0.enable = true;

  environment.defaultPackages = [
    pkgs.cyme
    pkgs.i2c-tools
  ];
}
