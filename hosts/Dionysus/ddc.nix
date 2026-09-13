{
  config,
  pkgs,
  ...
}: {
  hardware.i2c.enable = true;

  environment.defaultPackages = [
    pkgs.ddcutil
  ];

  users.users.fanghr.extraGroups = [config.hardware.i2c.group];
}
