{
  config,
  lib,
  ...
}: {
  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [
        "dm-snapshot"
        "dm-crypt"
        "vfat"
        "nls_cp437"
        "nls_iso8859-1"
        "usbhid"
        "r8169"
      ];
      network.enable = true;
      luks = {
        yubikeySupport = true;
        devices = {
          enc = {
            allowDiscards = true;
            device = "/dev/nvme0n1p2";
            preLVM = false;
            yubikey = {
              slot = 2;
              twoFactor = false;
              storage.device = "/dev/nvme0n1p1";
            };
          };
        };
      };
    };
    kernelModules = ["kvm-amd"];
  };

  services.fstrim.enable = true;

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/3AAF-0A9F";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-uuid/91a87427-5393-43c3-956e-9291796f1557";
      fsType = "btrfs";
      options = ["subvol=root" "noatime"];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/91a87427-5393-43c3-956e-9291796f1557";
      fsType = "btrfs";
      options = ["subvol=home" "noatime"];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/91a87427-5393-43c3-956e-9291796f1557";
      fsType = "btrfs";
      options = ["subvol=nix" "noatime"];
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/1455b8b6-d950-4a5f-9dcc-018b158ab109";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp10s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp11s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
