{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];
  nixpkgs.overlays = [inputs.nix-minecraft.overlay];

  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers.main = let
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
      environment = {
        # NOTE(chfanghr): Ticket granted by minecraft-krb5-ticket-refresher
        KRB5CCNAME = "FILE:/srv/minecraft/krb-ticket-cache";
      };
      files = {
        "world/carpet.conf" = "${carpetConf}";
      };
      symlinks = {
        "mods" = "${mods}";
        "server-icon.png" = ./server-icon.png;
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

  networking.firewall = {
    allowedTCPPorts = [
      config.services.minecraft-servers.servers.main.serverProperties.server-port
    ];
    allowedUDPPorts = [
      24454 # Simple Voice Chat
    ];
  };

  fileSystems."/srv/minecraft/main/world" = {
    device = "persephone.snow-dace.ts.net:/minecraft/main";
    fsType = "nfs";
    options = ["nfsvers=4.2" "x-systemd.automount" "noauto"];
  };

  nixpkgs.config.allowUnfree = lib.mkForce true;
}
