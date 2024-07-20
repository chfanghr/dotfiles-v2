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
          url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/tAwdMmKY/fabric-api-0.97.1%2B1.20.4.jar";
          sha512 = "161d5d8c67330cbda4ce825f92f23b96bfa884f881d5931c0375aba9ceef0f5e14b11c8607b5368fb6b72b796694a86a48271eecc3d9b63991f4b01352d66d5f";
        };
        fabric-carpet = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/yYzR60Xd/fabric-carpet-1.20.3-1.4.128%2Bv231205.jar";
          sha512 = "6ca0bd328a76b7c3c10eb0253cb57eba8791087775467fbe2217c7f938c0064700bdca4cbf358e7f2f3427ae50a6d63f520f2b1a549cb36da1cc718812f86375";
        };
        lithium = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/nMhjKWVE/lithium-fabric-mc1.20.4-0.12.1.jar";
          sha512 = "70bea154eaafb2e4b5cb755cdb12c55d50f9296ab4c2855399da548f72d6d24c0a9f77e3da2b2ea5f47fa91d1258df4d08c6c6f24a25da887ed71cea93502508";
        };
        no-chat-report = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/Pjto4zdj/NoChatReports-FABRIC-1.20.4-v2.6.1.jar";
          sha512 = "a2ca389f4024a2089dd1224713e23f356067fbfd27aaf6f3aa74ad28b75d6f0d19e0ed07e721035943964730a2d2a09473067d0d4db34ce7d5b7d6a15a6a5b42";
        };
      });
    in {
      enable = true;
      package = pkgs.fabricServers.fabric-1_20_4.override {loaderVersion = "0.15.11";};
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

  networking.firewall.allowedTCPPorts = [25565];

  nixpkgs.config.allowUnfree = lib.mkForce true;
}
