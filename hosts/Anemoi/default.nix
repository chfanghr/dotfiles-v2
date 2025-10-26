{inputs, ...}: {
  imports = [
    ./boot.nix
    ./disko-config.nix
    ./networking.nix
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
      nix.roles.consumer = true;
      ociHost = true;
    };
  };

  time.timeZone = "Asia/Singapore";

  networking.hostName = "Anemoi";

  users.users.fanghr.hashedPassword = "$y$j9T$h8nXdACDqyTyEO1AXMHvn/$YPSBkrTjrUmdk2DY6qH5TDepxd7yPm2hcPngIk9lVJD";
}
