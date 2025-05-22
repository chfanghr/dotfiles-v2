{
  inputs,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  imports = [
    ./containers
    ./backup.nix
    ./boot.nix
    ./disko.nix
    ./minecraft.nix
    ./mode.nix
    ./networking.nix
    ./qbittorrent.nix
    ./samba.nix
    ./stash.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
  ];

  dotfiles.nixos = {
    props = {
      hardware = {
        audio = true;
        bluetooth.enable = true;
        cpu.amd = true;
        gpu.amd.enable = true;
        emulation = true;
        vmHost = true;
      };
      nix.roles = {
        builder = true;
        consumer = true;
      };
      ociHost = true;
    };
    nix.builderPrivateKeyAgeSecret = ../../secrets/hestia-nix-cache-key.age;
  };

  time.timeZone = "Asia/Hong_Kong";

  users.users.fanghr.hashedPassword = "$y$j9T$JK4s34tHJmsXrZkf/VUXt.$rokP.46N.fjjjxBjD/sD9XUyFkF18PPChA4Yviq5uGB";

  networking.hostName = "Hestia";

  environment.systemPackages = with pkgs; [
    vulkan-tools
    nvtopPackages.amd
    libimobiledevice
    ifuse
  ];

  services = {
    tailscale-traefik.enable = true;

    usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
  };

  hestia.mode = mkDefault "server";

  specialisation.desktop.configuration.hestia.mode = "desktop";
}
