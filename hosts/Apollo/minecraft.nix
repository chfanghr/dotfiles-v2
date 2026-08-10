{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    attrValues
    toString
    ;
  inherit (pkgs) fetchurl;
  inherit (config.networking) hostName;
  inherit (config.services.tailscale-traefik) fqdn;

  user = "minecraft";
  group = "minecraft";

  mainSMPExporterPort = 25585;
  mainSMPServerPort = 25565;
  mainSMPVoiceChatPort = 24454;
  mainSMPRCONPort = 25575;
  mainSMPBluemapPort = 1800;
  mainSMPBluemapTraefikService = "${mainSMP}-bluemap";
  mainSMPBluemapPrefix = "/minecraft/main-smp";
  mainSMPBluemapStripPrefix = "mainSMPBluemapTraefikService-stripPrefix";

  mods = {
    fabric-api = fetchurl {
      url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/3gT0I5vt/fabric-api-0.156.0%2B26.2.jar";
      sha512 = "5bbc436d07f836cd90b88287e2ef27f1cd67e26185b2cd4a62cb2ae850eb74e5edbbc7ba7772e92ea91ebf35b263f8815421e3d5e7d2836cb28993ba1d534816";
    };
    carpet = fetchurl {
      url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/bGrLxJ8v/fabric-carpet-26.2%2Bv260616.jar";
      sha512 = "8b8fac6979bd3153f5cfb4faa6bab52e1357eab814492a6658f3c0e1ac2856ad37a626c0a03a0839c39abb7bf56661f77b09d05d10ac01173bcdd373a33c6265";
    };
    carpet-extra = fetchurl {
      url = "https://cdn.modrinth.com/data/VX3TgwQh/versions/Z5BJRYil/carpet-extra-26.2-26.2.jar";
      sha512 = "39bcfd81340cee04c2e9b9e61d628c297a13af2f96464d0081040ffa9e6336a64d36d95b76371aa00f343cef334bff3d0c6773cfb96994a9441e62ff7632da8d";
    };
    servux = fetchurl {
      url = "https://cdn.modrinth.com/data/zQhsx8KF/versions/qMld6z1t/servux-fabric-26.2-0.11.2.jar";
      sha512 = "28690e1fb4b6b7acba032297b0165df9d46cb43c56144e9afb94d5de37bcb0a302316cbb25979d0d1983008f4d1137ce6be859c35dbd5eee25dd018a8e8e17bb";
    };
    bluemap = fetchurl {
      url = "https://cdn.modrinth.com/data/swbUV1cr/versions/VTvifNPN/bluemap-5.22-fabric.jar";
      sha512 = "ec597df7e974f1f28baa15325373442968c9643a157a6d2627cd5c36f8841c3023f2c08023d203bcfa7e0e51bce69d4623ba712babb84da73bd40f0e0c7f4dbd";
    };
    lithium = fetchurl {
      url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/f7vZ0VWU/lithium-fabric-0.25.3%2Bmc26.2.jar";
      sha512 = "148b638f3c6229fbaf487120a2344a0af5e411a5aa6533d5db9d75da0a8c0d8304f63eb4cca13f4d03b2c9b4c23d559dd74c1d832422ef8a3087bd005e62a8bd";
    };
    no-chat-report = fetchurl {
      url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/uiY9tUaj/NoChatReports-FABRIC-26.2-v2.20.1.jar";
      sha512 = "139dd09e04cc66fe4745264ddfbe3249be6e956326c931eb9707f9a640bbc011a4f1fd5684d04ca90e1b473be55772b0279e5c2f935c2f2e85d054e2ab0a6923";
    };
    simple-voice-chat = fetchurl {
      url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/DKSq5wO6/voicechat-fabric-2.6.22%2B26.2.jar";
      sha512 = "eb45e75e8b031f3bb27e178ed44fd7b78ba681f077f5972e170726b4837146efd49c7b67d63a95ec4ce87e5672cf76bed85ac8fa7790a9e7ff7309a6c3f424ee";
    };
    fast-backups = fetchurl {
      url = "https://cdn.modrinth.com/data/ZHKrK8Rp/versions/EVNH1CA6/fastback-fabric-0.34.0%2B26.2.0.jar";
      sha512 = "70f5ad680e16e24b4c0130200a71a1301a288ae79672a9243388c1a843ad1215b0701a4fc5038aebb6c8cf744b4f6f61246f969b5f1ecd3cdb7a98bd0ab12b25";
    };
    spark = fetchurl {
      url = "https://cdn.modrinth.com/data/l6YH9Als/versions/iYFOl6lQ/spark-1.10.173-fabric.jar";
      sha512 = "1dcbf2b76ceacf07523afaeaf63d3625b0318077cc6ce588bb701aea4a494bc2a5179fd2ca5aeda9513c6a2248c2ec590387e8aec6ac9fd8e3d01760bbc3dbfb";
    };
    fabric-exporter = fetchurl {
      url = "https://cdn.modrinth.com/data/dbVXHSlv/versions/tuPsGk8g/fabricexporter-26.2-1.0.22.jar";
      sha512 = "80475cc389900c1d2e777ff1d0dd19776ba474eb2f96b73f1c1dbe8f349606a888ea35c7845cb517beef2ea3eaee0b5ce5ac39bea24a85f1165881b852760870";
    };
  };

  dataDir = "/data/minecraft";

  mainSMP = "main-smp";
in {
  options.apollo.mountpoints.minecraft.${mainSMP} = mkOption {
    type = types.str;
    default = "${dataDir}/${mainSMP}";
    readOnly = true;
  };

  config = {
    users = {
      users.${user} = {
        uid = 990;
        inherit group;
        isSystemUser = true;
      };
      groups.${group}.gid = 978;
    };

    systemd.tmpfiles.settings."40-minecraft" = {
      ${dataDir}.d = {
        inherit user group;
        mode = "0770";
      };

      ${config.apollo.mountpoints.minecraft.${mainSMP}}.d = {
        inherit user group;
        mode = "0770";
      };
    };

    services.minecraft-servers = {
      enable = true;
      eula = true;

      inherit dataDir;

      inherit user group;

      servers.${mainSMP} = {
        enable = true;
        package = pkgs.fabricServers.fabric-26_2.override {
          loaderVersion = "0.19.3";
          jre_headless = pkgs.jdk25;
        };
        serverProperties = {
          server-port = mainSMPServerPort;
          gamemode = "survival";
          enable-rcon = true;
          "rcon.port" = mainSMPRCONPort;
          "rcon.password" = 8964;
          level-seed = 826365176;
          difficulty = "hard";
          force-gamemode = true;
          view-distance = 16;
        };
        symlinks = {
          "mods" = "${pkgs.linkFarmFromDrvs "mods" (attrValues mods)}";
        };
        files = {
          "config/bluemap/core.conf" = "${pkgs.writeText "bluemap-core.conf" ''
            accept-download: true
            data: "bluemap"
            render-thread-count: 3
            update-cooldown: 60
            full-update-interval: 1440
            scan-for-mod-resources: true
            metrics: false
            log: {
              file: "bluemap/logs/debug.log"
              append: false
            }
          ''}";
          "config/bluemap/webserver.conf" = "${pkgs.writeText "bluemap-core.conf" ''
            enabled: true
            webroot: "bluemap/web"
            port: ${toString mainSMPBluemapPort}
            log: {
              file: "bluemap/logs/webserver.log"
              append: false
              format: "%1$s \"%3$s %4$s %5$s\" %6$s %7$s"
            }
          ''}";
          "world/carpet.conf" = "${pkgs.writeText "carpet.conf" ''
            commandPlayer true
            defaultLoggers mobcaps,tps
            accurateBlockPlacement true
          ''}";
          "config/exporter.properties" = "${pkgs.writeText "exporter.properties" ''
            server-port=${toString mainSMPExporterPort}
            update-interval=1000
            use-spark=true
            export-default-jvm-metrics=true
            strip-identifier-namespaces=true
            enable-loaded-chunks=true
            enable-mspt=true
            enable-tps=true
            enable-players-online=true
            enable-entities=true
            enable-handshakes=true
          ''}";
        };
        jvmOpts = "-Xmx8192M";
        path = [
          pkgs.git
          pkgs.git-lfs
        ];
      };
    };

    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [mainSMPServerPort];
      allowedUDPPorts = [mainSMPVoiceChatPort];
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "${hostName}-minecraft-${mainSMP}";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString mainSMPExporterPort}"
            ];
            labels.instance = hostName;
          }
        ];
      }
    ];

    services.traefik = {
      dynamicConfigOptions.http = {
        services.${mainSMPBluemapTraefikService}.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:${toString mainSMPBluemapPort}/";
          }
        ];

        middlewares.${mainSMPBluemapStripPrefix}.stripPrefix.prefixes = [mainSMPBluemapPrefix];

        routers = {
          ${mainSMPBluemapTraefikService} = {
            rule = "Host(`${fqdn}`) && PathPrefix(`${mainSMPBluemapPrefix}`)";
            service = mainSMPBluemapTraefikService;
            middlewares = [
              mainSMPBluemapStripPrefix
            ];
          };
        };
      };
    };
  };
}
