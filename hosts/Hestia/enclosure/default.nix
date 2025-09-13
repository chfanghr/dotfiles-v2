{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mkIf mkMerge optionalAttrs;
  inherit (config.hestia) mode enclosure;

  mkDefaultPath = name: "/data/enclosure/${name}";

  mkCfgFor = {
    name,
    mountPoint,
    user ? "root",
    group ? "root",
    mode ? "0755",
    sambaCfg ? null,
  }:
    {
      systemd.tmpfiles.settings."10-enclosure".${mountPoint}.d = {
        inherit user group mode;
      };
    }
    // optionalAttrs (sambaCfg != null) {
      services.samba.settings.${name} = {path = mountPoint;} // sambaCfg;
    };
in {
  options.hestia.enclosure = {
    attached = mkOption {
      type = types.bool;
      default = false;
    };

    poolName = mkOption {
      type = types.str;
      default = "zp-enclosure";
    };

    mountPoints = {
      qbittorrent = mkOption {
        type = types.str;
        default = mkDefaultPath "qbittorrent";
      };
      safe = mkOption {
        type = types.str;
        default = mkDefaultPath "safe";
      };
      slowStash = mkOption {
        type = types.str;
        default = mkDefaultPath "slow-stash";
      };
    };
  };

  config = mkIf (enclosure.attached && mode == "server") (mkMerge [
    {hestia.containers.qbittorrent.dataDir = enclosure.mountPoints.qbittorrent;}
    (mkCfgFor {
      name = "qbittorrent";
      mountPoint = enclosure.mountPoints.qbittorrent;
      user = config.hestia.containers.qbittorrent.user.name;
      group = config.hestia.containers.qbittorrent.group.name;
    })
    (mkCfgFor {
      name = "safe";
      mountPoint = enclosure.mountPoints.safe;
      user = config.dotfiles.nixos.props.users.superUser;
      sambaCfg = {
        "read only" = "no";
        "write list" = config.dotfiles.nixos.props.users.superUser;
        "force create mode" = "0600";
        "force directory mode" = "0700";
        "force group" = "root";
      };
      mode = "0700";
    })
    (mkCfgFor {
      name = "slow-stash";
      mountPoint = enclosure.mountPoints.slowStash;
      user = config.dotfiles.nixos.props.users.superUser;
      sambaCfg = {
        "read only" = "no";
        "write list" = config.dotfiles.nixos.props.users.superUser;
        "force create mode" = "0600";
        "force directory mode" = "0700";
        "force group" = "root";
      };
      mode = "0700";
    })
    (import ./disko-config.nix {
      inherit (enclosure) poolName mountPoints;
      inherit lib;
    })
  ]);
}
