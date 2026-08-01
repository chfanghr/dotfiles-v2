{
  lib,
  config,
  pkgs,
  ...
}: let
  steam-game-fullscreen = pkgs.writeShellApplication {
    name = "steam-game-fullscreen";
    runtimeInputs = [pkgs.gamescope];
    text = ''
      exec gamescope -f --force-grab-cursor --backend sdl -- "$@"
    '';
  };
in
  lib.mkIf (config.dotfiles.shared.props.purposes.graphical.gaming) (lib.mkMerge [
    {
      networking = {
        useNetworkd = false;
        networkmanager = {
          enable = true;
          appendNameservers = ["8.8.8.8" "1.1.1.1" "114.114.114.114"];
          dns = "systemd-resolved";
        };
      };

      services.resolved.enable = true;

      services.seatd.enable = true;

      security.polkit.enable = true;

      environment.systemPackages = with pkgs; [
        dualsensectl
        chiaki-ng
        prismlauncher
        protonup-qt
        steam-game-fullscreen
      ];

      nixpkgs.config.allowUnfree = true;
    }
    (lib.mkIf (!config.dotfiles.shared.props.hardware.steamdeck) {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        gamescopeSession.enable = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };
    })
  ])
