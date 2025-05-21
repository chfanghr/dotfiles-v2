{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkForce;
in {
  nixpkgs = {
    overlays = [inputs.nix-minecraft.overlay];
    config.allowUnfree = mkForce true;
  };

  hestia.containers.minecraft = {
    enable = true;

    containerName = "minecraft";

    user = {
      name = "minecraft-data";
      id = 990;
    };
    group = {
      name = "minecraft-data";
      id = 986;
    };

    lan = {
      veth = "ve-mc-lan";
      hostBridge =
        config
        .hestia
        .networking
        .${config.hestia.mode}
        .lanBridge
        .interface;
    };

    monitoring = {
      veth = "ve-mc-mon";
      hostAddress = "172.16.0.1";
      localAddress = "172.16.0.3";
    };

    worldsDir = "/data/minecraft";

    smp = {
      worldName = "smp";

      serverPackage = pkgs.fabricServers.fabric-1_21_4.override {loaderVersion = "0.16.10";};

      mods = {
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
      };

      carpetConfig = ''
        commandPlayer true
        defaultLoggers mobcaps,tps
        accurateBlockPlacement true
      '';

      port = 25565;

      otherSettings = {
        gamemode = "survival";
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

      jvmOptions = "-Xmx8192M";
    };
  };
}
