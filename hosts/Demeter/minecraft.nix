{
  inputs,
  pkgs,
  lib,
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
          url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/ocg4hG3t/fabric-api-0.100.8%2B1.20.6.jar";
          sha256 = "sha256-7w2k7KiqcxRp3eY9vuRRvGsNWBS8FAx0enApubsqjO8=";
        };
        fabric-carpet = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/iImwtlTX/fabric-carpet-1.20.6-1.4.141%2Bv240429.jar";
          sha256 = "sha256-lqq1ynWxkUP3Up9pFyKhj/lGHydeXbf56r/mTug52uo=";
        };
        carpet-extra = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/VX3TgwQh/versions/K5R1RGk8/carpet-extra-1.20.6-1.4.141.jar";
          sha256 = "sha256-YExC0MCkt/VX49xKQDdfah6H+OcH5b+FXcTG28UMdxg=";
        };
        lithium = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/5a3sPIH2/lithium-fabric-mc1.20.6-0.12.5.jar";
          sha256 = "sha256-yQEzF/tGZ0+QZfNfXV0XVhh3OPqAFNNS7U8lw/xpY/w=";
        };
        no-chat-report = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/MNkuIjea/NoChatReports-FABRIC-1.20.6-v2.7.1.jar";
          sha256 = "sha256-a1Fc+r0iDpY6s8ThiHyfa5q4JBMpR+9VB+r+zTzvQds=";
        };
        simple-voice-chat = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/FGDBZ2bv/voicechat-fabric-1.20.6-2.5.22.jar";
          sha256 = "sha256-p7vLXyKE0Y0VdoCHkLeXYfi/WFm49cGxOZHGKHXgivo=";
        };
      });
    in {
      enable = true;
      package = pkgs.fabricServers.fabric-1_20_6.override {loaderVersion = "0.16.10";};
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
        motd = "Jesus Fucking Christ";
        difficulty = "hard";
        force-gamemode = true;
        allow-flight = true;
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      25565
      24454 # Simple Voice Chat
    ];
    allowedUDPPorts = [
      24454
    ];
  };

  nixpkgs.config.allowUnfree = lib.mkForce true;
}
