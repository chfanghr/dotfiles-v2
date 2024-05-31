{
  config,
  lib,
  ...
}:
lib.mkMerge [
  {
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    boot.loader.systemd-boot.consoleMode = lib.mkDefault "auto";
    services = {
      fstrim.enable = true;
      fwupd.enable = true;
    };
  }
  (lib.mkIf config.dotfiles.shared.props.purposes.graphical.gaming {
    hardware = {
      xone.enable = true;
      steam-hardware.enable = true;
    };
  })
]
