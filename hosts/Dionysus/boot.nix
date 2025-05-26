{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    plymouth.enable = false;

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
      network = {
        enable = true;
        # ssh = {
        #   enable = true;
        # };
      };
      luks = {
        yubikeySupport = true;
        devices = {
          enc_root = {
            allowDiscards = true;
            # device = "/dev/nvme1n1p2"; # handled by disko
            preLVM = false;
            yubikey = {
              slot = 2;
              twoFactor = false;
              storage.device = "/dev/disk/by-uuid/12CE-A600";
            };
          };
        };
      };
    };
  };
}
