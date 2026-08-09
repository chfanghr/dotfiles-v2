{
  config,
  inputs ? null,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption optional optionalAttrs types;

  cfg = config.services.minecraft-prometheus-exporter;
  localPackages =
    if inputs != null && inputs ? self
    then inputs.self.packages.${pkgs.stdenv.hostPlatform.system}
    else throw "services.minecraft-prometheus-exporter.package must be set when inputs.self is not available";

  serviceName = "minecraft-prometheus-exporter";
  defaultUser = serviceName;
  defaultGroup = defaultUser;

  startArgs = lib.cli.toCommandLineShellGNU {} (
    {
      "web.listen-address" = cfg.listenAddress;
      "web.telemetry-path" = cfg.telemetryPath;
      "mc.rcon-address" = cfg.rconAddress;
      "mc.name-source" = cfg.nameSource;
      "log.level" = cfg.logLevel;
      "log.format" = cfg.logFormat;
    }
    // optionalAttrs (cfg.webConfigFile != null) {
      "web.config.file" = cfg.webConfigFile;
    }
    // optionalAttrs cfg.disableExporterMetrics {
      "web.disable-exporter-metrics" = true;
    }
    // optionalAttrs (cfg.world != null) {
      "mc.world" = cfg.world;
    }
    // optionalAttrs (cfg.configFile != null) {
      "mc.config-path" = cfg.configFile;
    }
    // optionalAttrs (cfg.modServerStats != null) {
      "mc.mod-server-stats" = cfg.modServerStats;
    }
  );
in {
  options.services.minecraft-prometheus-exporter = {
    enable = mkEnableOption "Minecraft Prometheus exporter";

    package = mkOption {
      type = types.package;
      default = localPackages.minecraft-prometheus-exporter;
      defaultText = lib.literalExpression ''inputs.self.packages.''${pkgs.stdenv.hostPlatform.system}.minecraft-prometheus-exporter'';
    };

    user = mkOption {
      type = types.str;
      default = defaultUser;
    };

    group = mkOption {
      type = types.str;
      default = defaultGroup;
    };

    port = mkOption {
      type = types.port;
      default = 9150;
    };

    listenAddress = mkOption {
      type = types.str;
      default = ":${toString cfg.port}";
      example = "127.0.0.1:9150";
    };

    telemetryPath = mkOption {
      type = types.str;
      default = "/metrics";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };

    webConfigFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/run/secrets/minecraft-exporter-web.yml";
    };

    disableExporterMetrics = mkOption {
      type = types.bool;
      default = false;
    };

    configFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/etc/minecraft-exporter/config.yml";
    };

    world = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/var/lib/minecraft/world";
    };

    rconAddress = mkOption {
      type = types.str;
      default = ":25575";
    };

    rconPasswordFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/run/agenix/minecraft-rcon-password";
    };

    nameSource = mkOption {
      type = types.enum ["offline" "bukkit" "mojang"];
      default = "mojang";
    };

    modServerStats = mkOption {
      type = types.nullOr (types.enum ["papermc" "purpurmc" "forge" "fabric"]);
      default = null;
    };

    logLevel = mkOption {
      type = types.enum ["debug" "info" "warn" "error"];
      default = "info";
    };

    logFormat = mkOption {
      type = types.enum ["logfmt" "json"];
      default = "logfmt";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    systemdServiceName = mkOption {
      type = types.str;
      default = serviceName;
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.port];

    users.users = mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = mkIf (cfg.group == defaultGroup) {
      ${defaultGroup} = {};
    };

    systemd.services.${serviceName} = {
      description = "Minecraft Prometheus exporter";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target"];

      script = ''
        ${lib.optionalString (cfg.rconPasswordFile != null) ''
          export MC_RCON_PASSWORD="$(${lib.getExe' pkgs.coreutils "cat"} "$CREDENTIALS_DIRECTORY/rcon-password")"
        ''}
        exec ${lib.getExe cfg.package} ${startArgs} ${lib.escapeShellArgs cfg.extraFlags}
      '';

      serviceConfig = {
        Restart = "on-failure";
        User = cfg.user;
        Group = cfg.group;
        LoadCredential = optional (cfg.rconPasswordFile != null) "rcon-password:${cfg.rconPasswordFile}";
        DynamicUser = false;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
        RestrictNamespaces = true;
      };
    };
  };
}
