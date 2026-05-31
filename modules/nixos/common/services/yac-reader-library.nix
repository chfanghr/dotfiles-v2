{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    generators
    cli
    mkEnableOption
    types
    mkOption
    mkIf
    mkPackageOption
    hasPrefix
    escapeShellArg
    ;

  cfg = config.services.yac-reader-library;

  defaultUser = "yac-reader-library";
  defaultGroup = defaultUser;

  serviceName = "yac-reader-library";
  stateDir = "/var/lib/${serviceName}";

  iniType = (pkgs.formats.ini {}).type;
  generatedSettings = generators.toINI {} cfg.settings;
  settingsFile = pkgs.writeText "YACReaderLibrary.ini" cfg.settingsFile;

  startArgs = cli.toCommandLineShellGNU {} {
    loglevel = cfg.logLevel;
    port = cfg.port;
  };
in {
  options.services.yac-reader-library = {
    enable = mkEnableOption "YACReaderLibraryServer";

    package = mkPackageOption pkgs "yacreader" {};

    libraryRoot = mkOption {
      type = types.str;
      example = "/srv/comics";
    };

    libraryName = mkOption {
      type = types.str;
      default = "Library";
    };

    port = mkOption {
      type = types.nullOr types.port;
      default = null;
      example = 8080;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };

    user = mkOption {
      type = types.str;
      default = defaultUser;
    };

    group = mkOption {
      type = types.str;
      default = defaultGroup;
    };

    logLevel = mkOption {
      type = types.enum [
        "trace"
        "info"
        "debug"
        "warn"
        "error"
      ];
      default = "info";
    };

    settings = mkOption {
      type = iniType;
      default = {};
      example = {
        libraryConfig = {
          IMPORT_COMIC_INFO_XML_METADATA = false;
          UPDATE_LIBRARIES_AT_STARTUP = true;
          UPDATE_LIBRARIES_PERIODICALLY = true;
          UPDATE_LIBRARIES_PERIODICALLY_INTERVAL = 2;
        };
      };
      description = ''
        Settings written to YACReaderLibrary.ini. Available settings are documented at
        <https://github.com/YACReader/yacreader/blob/develop/YACReaderLibraryServer/SETTINGS_README.md>.
      '';
    };

    settingsFile = mkOption {
      type = types.str;
      default = generatedSettings;
      defaultText = lib.literalExpression "lib.generators.toINI { } config.services.yac-reader-library.settings";
    };

    systemdServiceName = mkOption {
      type = types.str;
      default = serviceName;
      readOnly = true;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hasPrefix "/" cfg.libraryRoot;
        message = "services.yac-reader-library.libraryRoot must be an absolute path.";
      }
      {
        assertion = cfg.openFirewall -> cfg.port != null;
        message = "services.yac-reader-library.openFirewall requires services.yac-reader-library.port to be set.";
      }
    ];

    users.users = mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        isSystemUser = true;
        group = cfg.group;
        home = stateDir;
        createHome = true;
      };
    };

    users.groups = mkIf (cfg.group == defaultGroup) {
      ${defaultGroup} = {};
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.port];

    systemd.tmpfiles.settings."10-yac-reader".${cfg.libraryRoot}.d = {
      mode = "0755";
      user = cfg.user;
      group = cfg.group;
    };

    systemd.services.${serviceName} = {
      description = "YACReaderLibraryServer";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      path = [
        cfg.package
        pkgs.coreutils
        pkgs.gnugrep
      ];

      environment = {
        HOME = stateDir;
        XDG_CONFIG_HOME = "${stateDir}/.config";
        XDG_DATA_HOME = "${stateDir}/.local/share";
      };

      preStart = ''
        mkdir -p ${escapeShellArg cfg.libraryRoot} "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"
        install -Dm0644 ${settingsFile} "$XDG_DATA_HOME/YACReader/YACReaderLibrary/YACReaderLibrary.ini"

        if ! YACReaderLibraryServer list-libraries | grep -Fqx ${escapeShellArg "${cfg.libraryName} : ${cfg.libraryRoot}"}; then
          YACReaderLibraryServer create-library ${escapeShellArg cfg.libraryName} ${lib.escapeShellArg cfg.libraryRoot}
        fi
      '';

      script = ''
        exec YACReaderLibraryServer start ${startArgs}
      '';

      serviceConfig = {
        Restart = "on-failure";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = serviceName;
        WorkingDirectory = stateDir;
      };
    };
  };
}
