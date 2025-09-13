o @ {
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mkIf mkMerge;
  inherit (config.hestia) mode withEnclosureAttached;

  poolName = "zp-enclosure";

  qbtMountPoint = "/data/enclosure/qbittorrent";
  safeMountPoint = "/data/enclosure/safe";
in {
  options.hestia.withEnclosureAttached = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf (withEnclosureAttached && mode == "server") (mkMerge [
    {
      hestia.containers.qbittorrent.dataDir = qbtMountPoint;

      systemd.tmpfiles.settings."10-enclosure" = {
        ${qbtMountPoint}.d = {
          user = config.hestia.containers.qbittorrent.user.name;
          group = config.hestia.containers.qbittorrent.group.name;
          mode = "0755";
        };
        ${safeMountPoint}.d = {
          user = config.dotfiles.nixos.props.users.superUser;
          group = "root";
          mode = "0700";
        };
      };

      services.samba.settings.safe = {
        path = safeMountPoint;
        "read only" = "no";
        "write list" = "${config.dotfiles.nixos.props.users.superUser}";
        "force create mode" = "0600";
        "force directory mode" = "0700";
        "force group" = "root";
      };
    }
    (import ./disko-enclosure.nix {inherit qbtMountPoint safeMountPoint poolName;} o)
  ]);
}
