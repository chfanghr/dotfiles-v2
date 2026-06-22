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

  libraryType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        example = "Comics";
      };

      root = mkOption {
        type = types.str;
        example = "/srv/comics";
      };
    };
  };

  startArgs = cli.toCommandLineShellGNU {} {
    loglevel = cfg.logLevel;
    port = cfg.port;
  };
in {
  options.services.yac-reader-library = {
    enable = mkEnableOption "YACReaderLibraryServer";

    package = mkPackageOption pkgs "yacreader" {};

    libs = mkOption {
      type = types.listOf libraryType;
      example = [
        {
          name = "Comics";
          root = "/srv/comics";
        }
        {
          name = "Manga";
          root = "/srv/manga";
        }
      ];
      description = ''
        Library root directories to manage. Each entry becomes a separate YACReader library.
      '';
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
        assertion = cfg.libs != [] && lib.all (library: hasPrefix "/" library.root) cfg.libs;
        message = "services.yac-reader-library.libs must contain at least one absolute path.";
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

    systemd.tmpfiles.settings."10-yac-reader" = lib.listToAttrs (map (library:
      lib.nameValuePair library.root {
        d = {
          mode = "0775";
          user = cfg.user;
          group = cfg.group;
        };
      })
    cfg.libs);

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
                mkdir -p ${lib.concatStringsSep " " (map (library: escapeShellArg library.root) cfg.libs)} "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"
                install -Dm0644 ${settingsFile} "$XDG_DATA_HOME/YACReader/YACReaderLibrary/YACReaderLibrary.ini"

        ${lib.concatMapStringsSep "\n" (library: ''
            if ! YACReaderLibraryServer list-libraries | grep -Fqx ${escapeShellArg "${library.name} : ${library.root}"}; then
              YACReaderLibraryServer create-library ${escapeShellArg library.name} ${escapeShellArg library.root}
            fi
          '')
          cfg.libs}
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
