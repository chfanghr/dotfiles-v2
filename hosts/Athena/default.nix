{inputs, ...}: {
  imports = [
    ./disko.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
  ];

  networking.hostName = "Athena";

  dotfiles.nixos.props = {
    nix.roles.consumer = true;
    users = {
      rootAccess = true;
      fanghr.disableHm = true;
    };
    hardware = {
      cpu.intel = true;
      # vmHost = true;
    };
  };

  time.timeZone = "Asia/Hong_Kong";

  users.users = {
    fanghr.hashedPassword = "$y$j9T$tn5fAVwNCepbQ4xrimozH0$FhC1TMwwwcKFfDFtX4qx23AUhHRee9o2GviL5dM35b.";
    root.hashedPassword = "$y$j9T$LclEAQG.FK8eoV2.mc6ku1$dDc7MUikq2gi7Jpbo4AeQsnkdUjEFsfJ0XbhMY3yedA";
  };

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "igc"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix.gc.options = "--delete-older-than +8";
}
