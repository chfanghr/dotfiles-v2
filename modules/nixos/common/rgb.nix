{
  lib,
  config,
  ...
}:
lib.mkIf (config.dotfiles.hasProp "has-rgb") {
  environment.systemPackages = [config.services.openrgb.package];

  services.hardware.openrgb = {
    enable = true;
    motherboard = config.dotfiles.hardware.rgb.motherboard;
  };

  hardware.i2c.enable = true;

  boot.kernelModules = config.dotfiles.hardware.rgb.extraKernelModules;
}
