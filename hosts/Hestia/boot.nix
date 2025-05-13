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
        # TODO: This should be handled by disko
        devices.zfs-keys = {
          preLVM = false;
          yubikey = {
            slot = 2;
            twoFactor = false;
            storage.device = "/dev/disk/by-partlabel/disk-ssd-1-esp";
          };
          postOpenCommands = ''
            mkdir -p /zfs-keys
            mount /dev/mapper/zfs-keys /zfs-keys
            zpool import -f -a
            zfs load-key zp-striped/enc
            zfs load-key zp-mirrored/enc
          '';
        };
      };
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    plymouth.enable = false;
  };

  services.zfs = {
    trim.enable = true;

    autoScrub = {
      enable = true;
      pools = ["rpool"];
    };
  };
}
