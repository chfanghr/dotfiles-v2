{
  config,
  secrets,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) genAttrs' nameValuePair;

  secretName = "apollo-smb-credential";

  # https://wiki.nixos.org/wiki/Samba#CIFS_mount_configuration
  automountOpts = [
    "x-systemd.automount"
    "x-systemd.idle-timeout=60"
    "x-systemd.mount-timeout=5s"
    "x-systemd.device-timeout=5s"
    "user"
    "users"
    "nofail"
    "credentials=${config.age.secrets.${secretName}.path}"
    "uid=fanghr"
  ];
  localPrefix = "/data/apollo/smb";
  mkShare = s:
    nameValuePair "${localPrefix}/${s}" {
      device = "//apollo.snow-dace.ts.net/${s}";
      fsType = "cifs";
      options = automountOpts;
    };
in {
  environment.systemPackages = [pkgs.cifs-utils];

  age.secrets.${secretName}.file = "${secrets}/dionysus-apollo-smb-credential.age";

  fileSystems = genAttrs' ["qbittorrent" "slow-stash"] mkShare;
}
