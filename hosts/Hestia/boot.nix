{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_6_12;

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
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
          enc_root = {
            preLVM = false;
            yubikey = {
              slot = 2;
              twoFactor = false;
              storage.device = "/dev/disk/by-uuid/E0DF-130A";
            };
          };
        };
      };
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    plymouth.enable = false;
  };
}
