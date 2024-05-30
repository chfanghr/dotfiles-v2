{
  config,
  lib,
  ...
}:
lib.mkMerge [
  {
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    services.fwupd.enable = true;
    boot.loader.systemd-boot.consoleMode = lib.mkDefault "auto";
  }
  (lib.mkIf config.dotfiles.shared.props.purposes.graphical.gaming {
    hardware = {
      xone.enable = true;
      steam-hardware.enable = true;
    };
  })
]
