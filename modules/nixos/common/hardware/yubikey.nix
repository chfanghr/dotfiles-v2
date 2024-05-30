{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (!config.dotfiles.shared.props.purposes.vps) {
  services.pcscd.enable = true;
  hardware.gpgSmartcards.enable = true;

  services.udev = {
    packages = [
      pkgs.yubikey-personalization
      pkgs.libu2f-host
    ];
  };
}
