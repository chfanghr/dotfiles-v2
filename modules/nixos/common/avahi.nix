{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.dotfiles.hasProp "is-on-lan")
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

    allowInterfaces = config.dotfiles.networking.lanInterfaces;
  };
}
