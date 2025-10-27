{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./boot.nix
    ./disko-config.nix
    ./networking.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
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
      nix.roles.consumer = true;
      ociHost = true;
    };
  };

  time.timeZone = "Asia/Singapore";

  networking.hostName = "Anemoi";

  users.users.fanghr.hashedPassword = "$y$j9T$h8nXdACDqyTyEO1AXMHvn/$YPSBkrTjrUmdk2DY6qH5TDepxd7yPm2hcPngIk9lVJD";

  nix.settings.download-buffer-size = 1048576000;

  environment.defaultPackages = [
    pkgs.sbctl
  ];

  services.prometheus.enable = lib.mkForce false;

  nixpkgs.hostPlatform = "x86_64-linux";
}
