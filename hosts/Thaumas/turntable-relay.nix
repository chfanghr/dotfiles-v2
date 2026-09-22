{
  pkgs,
  config,
  ...
}: {
  services.pipewire.systemWide = true;
  systemd.user.services.wireplumber.wantedBy = ["default.target"];
  users.users.fanghr = {
    linger = true;
    extraGroups = ["audio" "pipewire" config.hardware.i2c.group];
  };

  hardware = {
    raspberry-pi."4" = {
      i2c1.enable = true;
      gpio.enable = true;
      apply-overlays-dtmerge.enable = true;
    };
    deviceTree.filter = "bcm2711-rpi-4-b.dtb"; # TODO: improve and upstream this? i2c0if doesn't exist on CM4.
  };
  environment.defaultPackages = [
    pkgs.cyme
    pkgs.i2c-tools
    pkgs.lm_sensors
  ];
}
