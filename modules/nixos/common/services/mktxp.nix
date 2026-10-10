{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) filterAttrs getExe literalExpression mapAttrs mkEnableOption mkIf mkOption optionalAttrs types;

  cfg = config.services.prometheus.exporters.mktxp;

  iniValueType = types.oneOf [
    types.bool
    types.int
    types.path
    types.str
  ];

  iniSectionType = types.attrsOf (types.nullOr iniValueType);

  stripNulls = filterAttrs (_: value: value != null);

  routerConfigFile = (pkgs.formats.ini {}).generate "mktxp.conf" (
    optionalAttrs (cfg.defaultConfig != {}) {default = stripNulls cfg.defaultConfig;}
    // mapAttrs (_: stripNulls) cfg.routerConfigs
  );

  exporterConfigFile = (pkgs.formats.ini {}).generate "_mktxp.conf" {
    MKTXP = stripNulls cfg.exporterConfig;
  };
in {
  options.services.prometheus.exporters.mktxp = {
    enable = mkEnableOption "MKTXP RouterOS metrics exporter";

    package = mkOption {
      type = types.package;
      default = pkgs.mktxp;
      defaultText = literalExpression "pkgs.mktxp";
      description = "MKTXP package to use.";
    };

    user = mkOption {
      type = types.str;
      default = "mktxp";
      description = "User account under which MKTXP runs.";
    };

    group = mkOption {
      type = types.str;
      default = "mktxp";
      description = "Group account under which MKTXP runs.";
    };

    defaultConfig = mkOption {
      type = iniSectionType;
      default = {};
      example = {
        username = "mktxp_user";
        credentials_file = "/run/agenix/mktxp-router.yaml";
        port = 8728;
        use_ssl = false;
        interface = true;
      };
      description = "Values written to the `[default]` section of `mktxp.conf`.";
    };

    routerConfigs = mkOption {
      type = types.attrsOf iniSectionType;
      default = {};
      example = {
        Core-Router = {
          hostname = "192.168.88.1";
          custom_labels = "role:gateway";
        };
      };
      description = "Router sections written to `mktxp.conf`.";
    };

    exporterConfig = mkOption {
      type = iniSectionType;
      default = {};
      example = {
        listen = "127.0.0.1:49090";
        fetch_routers_in_parallel = true;
        max_worker_threads = 5;
        max_scrape_duration = 30;
      };
      description = "Values written to the `[MKTXP]` section of `_mktxp.conf`.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.routerConfigs != {};
        message = "services.prometheus.exporters.mktxp.routerConfigs must define at least one router";
      }
    ];

    environment.etc = {
      "mktxp/mktxp.conf".source = routerConfigFile;
      "mktxp/_mktxp.conf".source = exporterConfigFile;
    };

    users.users = mkIf (cfg.user == "mktxp") {
      mktxp = {
        isSystemUser = true;
        group = cfg.group;
        home = "/var/lib/mktxp";
      };
    };

    users.groups = mkIf (cfg.group == "mktxp") {
      mktxp = {};
    };

    systemd.services.mktxp = {
      description = "MKTXP RouterOS metrics exporter";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        ExecStart = "${getExe cfg.package} --cfg-dir /etc/mktxp export";
        Restart = "on-failure";
        RestartSec = "10s";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "mktxp";
        WorkingDirectory = "/var/lib/mktxp";

        CapabilityBoundingSet = "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  };
}
