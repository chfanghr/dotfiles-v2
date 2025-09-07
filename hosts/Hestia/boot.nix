{pkgs, ...}: {
  boot = {
    useLatestZfsCompatibleKernel = true;

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "mt7925e"
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

      luks.yubikeySupport = true;
    };

    loader = {
      systemd-boot = {
        enable = true;
        extraFiles."crypt-storage/default" =
          pkgs.writeText "hestia-yubikey-salt" "213c912cc567929a2df2f368291abb1d\n1000000";
      };
      efi.canTouchEfiVariables = true;
    };

    plymouth.enable = false;

    binfmt.emulatedSystems = [
      "loongarch64-linux"
      "aarch64-linux"
    ];
  };

  services.hardware.bolt.enable = true;
}
