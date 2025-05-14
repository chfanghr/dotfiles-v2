{
  lib,
  config,
  inputs,
  ...
}: let
  containerName = "minecraft";

  macVlanNic = "enp195s0";
  virtualNic = "mv-${macVlanNic}";

  monitoringVeth = "ve-mc";

  hostAddress = "172.16.0.1";
  localAddress = "172.16.0.3";

  minecraftHostUser = "minecraft-data";
  minecraftHostGroup = "minecraft-data";
  minecraftUid = 990;
  minecraftGid = 986;

  minecraftDataMountpoint = "/data/minecraft";
in {
  users = {
    users.${minecraftHostUser} = {
      uid = minecraftUid;
      group = minecraftHostGroup;
      isSystemUser = true;
    };

    groups.${minecraftHostGroup}.gid = minecraftGid;
  };

  containers.${containerName} = {
    autoStart = true;

    privateNetwork = true;
    enableTun = true;
    macvlans = ["enp195s0"];
    extraVeths.${monitoringVeth} = {
      inherit hostAddress localAddress;
    };

    bindMounts.minecraft-data = {
      hostPath = minecraftDataMountpoint;
      mountPoint = minecraftDataMountpoint;
      isReadOnly = false;
    };

    config = {
      config,
      pkgs,
      ...
    }: {
      imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];

      nixpkgs = {
        overlays = [inputs.nix-minecraft.overlay];
        config.allowUnfree = lib.mkForce true;
      };

      networking = {
        enableIPv6 = true;
        useNetworkd = true;
        interfaces.${virtualNic}.useDHCP = true;
        useHostResolvConf = lib.mkForce false;
        firewall = {
          enable = true;
          interfaces.${monitoringVeth}.allowedTCPPorts = [
            config.services.prometheus.exporters.node.port
          ];
        };
      };

      services = {
        resolved.enable = true;
        tailscale.enable = true;

        prometheus.exporters.node = {
          enable = true;
          listenAddress = localAddress;
        };

        minecraft-servers = {
          enable = true;
          eula = true;

          servers = {
            smp = let
              mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
                fabric-api = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/ZNwYCTsk/fabric-api-0.118.0%2B1.21.4.jar";
                  sha256 = "sha256-EDrLCs4eCeI4e8oe03vLVlYEESwRlhneCQ5vrjswPFM=";
                };
                fabric-carpet = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/aVB2lYQQ/fabric-carpet-1.21.4-1.4.161%2Bv241203.jar";
                  sha256 = "sha256-AxFO/ZnFl6Y4ZD2OuXt9xIUxjAB3UHddil6MhmtE7XY=";
                };
                carpet-extra = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/VX3TgwQh/versions/jLwlJK0f/carpet-extra-1.21.4-1.4.161.jar";
                  sha256 = "sha256-b/7KVVsUNTGkzlru6ISSi/ZDBgLQi2kOvBb3iEHXrjE=";
                };
                lithium = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/kLc5Oxr4/lithium-fabric-0.14.8%2Bmc1.21.4.jar";
                  sha256 = "sha256-tRIF9xDNCcY5scktZLxSG6bZD/pej0GVHspeo2kSFT0=";
                };
                no-chat-report = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/9xt05630/NoChatReports-FABRIC-1.21.4-v2.11.0.jar";
                  sha256 = "sha256-1jMJbw5wL/PwsNSEHs4MHJpjyvPVhbhiP59dnXRQJwI=";
                };
                simple-voice-chat = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/DWQCr1uB/voicechat-fabric-1.21.4-2.5.28.jar";
                  sha256 = "sha256-/MCQyBXPG+BPGKFQjtKAE0VNoZ2hEnpov/rco5wjWYE=";
                };
                advanced-backup = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/Jrmoreqs/versions/g1B8uoKN/AdvancedBackups-fabric-1.21.2-3.7.1.jar";
                  sha256 = "sha256-h/wKJEWqMP4531kMyNoj2CMblZx4v6Vrk1w/+ruHwRs=";
                };
                servux = pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/zQhsx8KF/versions/EQhfaAYE/servux-fabric-1.21.4-0.5.2.jar";
                  sha256 = "sha256-2u8hPQGqt5PkndJWUBC0/ybqIO1XzC5fMvVTo43U7aE=";
                };
              });

              carpetConf = pkgs.writeText "carpet.conf" ''
                commandPlayer true
                defaultLoggers mobcaps,tps
                accurateBlockPlacement true
              '';
            in {
              enable = true;
              package = pkgs.fabricServers.fabric-1_21_4.override {loaderVersion = "0.16.10";};
              files = {
                "world/carpet.conf" = "${carpetConf}";
              };
              symlinks = {
                "mods" = "${mods}";
              };
              jvmOpts = "-Xmx8192M";
              serverProperties = {
                gamemode = "survival";
                server-port = 25565;
                enable-rcon = true;
                "rcon.port" = 25575;
                "rcon.password" = 8964;
                level-seed = 8964;
                motd = "包蜜进";
                difficulty = "hard";
                force-gamemode = true;
                allow-flight = true;
                view-distance = 16;
              };
            };
          };
        };
      };

      fileSystems."${config.services.minecraft-servers.dataDir}/smp/world" = {
        device = "${minecraftDataMountpoint}/smp";
        options = ["bind"];
      };

      users = {
        users.minecraft.uid = minecraftUid;
        groups.minecraft.gid = minecraftGid;
      };

      systemd.network = {
        wait-online.ignoredInterfaces = [virtualNic];
        networks."40-${virtualNic}".networkConfig.IPv6AcceptRA = true;
      };

      time.timeZone = "Asia/Hong_Kong";

      system.stateVersion = "24.11";
    };
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "${config.networking.hostName}-minecraft-node";
      static_configs = [
        {
          targets = [
            "${localAddress}:${toString config.containers.${containerName}.config.services.prometheus.exporters.node.port}"
          ];
          labels.instance = "${config.networking.hostName}-minecraft";
        }
      ];
    }
  ];
}
