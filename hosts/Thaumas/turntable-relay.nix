{
  pkgs,
  config,
  inputs,
  ...
}: {
  services.pipewire.systemWide = true;

  users.users.fanghr.extraGroups = ["audio" "pipewire" config.hardware.i2c.group];

  hardware.raspberry-pi."4" = {
    i2c1.enable = true;
    gpio.enable = true;
  };

  environment.defaultPackages = [
    pkgs.cyme
    pkgs.i2c-tools
    pkgs.lm_sensors
    inputs.audio-relay.packages.${pkgs.stdenv.hostPlatform.system}.audio-relay
  ];
}
