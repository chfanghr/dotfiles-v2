{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkIf mkDefault;
  cfg = config.services.qbittorrent-custom;
  configDir = "${cfg.dataDir}/.config";
  openFilesLimit = 4096;
in {
  options.services.qbittorrent-custom = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Run qBittorrent headlessly as systemwide daemon
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.qbittorrent-nox;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
      description = ''
        The directory where qBittorrent will create files.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        User account under which qBittorrent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        Group under which qBittorrent runs.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = ''
        qBittorrent web UI port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open services.qBittorrent.port to the outside network.
      '';
    };

    openFilesLimit = mkOption {
      type = types.ints.unsigned;
      default = openFilesLimit;
      description = ''
        Number of files to allow qBittorrent to open.
      '';
    };

    systemdServiceName = mkOption {
      type = types.str;
      default = "qbittorrent";
      readOnly = true;
    };

    confirmLegalNotice = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.qbittorrent];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port 56621 9000];
      allowedUDPPorts = [cfg.port 56621 9000];
    };

    systemd.services.${cfg.systemdServiceName} = {
      after = ["network.target"];
      description = "qBittorrent Daemon";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/qbittorrent-nox ${lib.cli.toGNUCommandLineShell {optionValueSeparator = "=";} {
            profile = configDir;
            webui-port = cfg.port;
            confirm-legal-notice = cfg.confirmLegalNotice;
          }}
        '';
        # To prevent "Quit & shutdown daemon" from working; we want systemd to
        # manage it!
        Restart = "on-success";
        User = cfg.user;
        Group = cfg.group;
        UMask = "022";
        LimitNOFILE = cfg.openFilesLimit;
        StateDirectory = "qbittorrent";
      };
    };

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        home = cfg.dataDir;
        homeMode = "755";
        createHome = true;
        description = "qBittorrent Daemon user";
        isSystemUser = true;
      };
    };

    users.groups =
      mkIf (cfg.group == "qbittorrent") {qbittorrent = {gid = mkDefault null;};};
  };
}
