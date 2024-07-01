{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.dotfiles.shared.props.networking.home.onLanNetwork
  && config.dotfiles.nixos.networking.lanInterfaces != [])
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      workstation = true;
      hinfo = true;
      domain = true;
      addresses = true;
    };
    ipv6 = true;
    extraServiceFiles = {
      ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
      sftp = "${pkgs.avahi}/etc/avahi/services/sftp-ssh.service";
    };

    allowInterfaces = config.dotfiles.nixos.networking.lanInterfaces;
  };
}
