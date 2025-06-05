{inputs, ...}: {
  imports = [
    ./boot.nix
    ./disko.nix
    ./impermanence.nix
    ./networking.nix
    ./vpn-servers.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
    inputs.impermanence.nixosModules.default
  ];

  networking.hostName = "Athena";

  dotfiles.nixos.props = {
    nix.roles.consumer = true;
    users.rootAccess = true;
    hardware.cpu.intel = true;
  };

  time.timeZone = "Asia/Hong_Kong";

  users.users = {
    fanghr.hashedPassword = "$y$j9T$tn5fAVwNCepbQ4xrimozH0$FhC1TMwwwcKFfDFtX4qx23AUhHRee9o2GviL5dM35b.";
    root.hashedPassword = "$y$j9T$LclEAQG.FK8eoV2.mc6ku1$dDc7MUikq2gi7Jpbo4AeQsnkdUjEFsfJ0XbhMY3yedA";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
