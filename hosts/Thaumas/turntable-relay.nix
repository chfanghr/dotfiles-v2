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
    i2c.enable = true;
    raspberry-pi."4" = {
      i2c1.enable = true;
      gpio.enable = true;
    };
  };

  environment.defaultPackages = [
    pkgs.cyme
    pkgs.i2c-tools
    pkgs.lm_sensors
  ];
}
