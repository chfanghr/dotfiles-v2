{
  boot = {
    useLatestZfsCompatibleKernel = true;

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "iwlwifi"
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
      };
      efi.canTouchEfiVariables = true;
    };

    plymouth.enable = false;

    binfmt.emulatedSystems = [
      "loongarch64-linux"
      "aarch64-linux"
    ];
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
