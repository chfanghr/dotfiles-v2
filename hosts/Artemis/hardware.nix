{
  boot = {
    initrd.availableKernelModules = [
      "sdhci_pci"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "nvme"
      "r8169"
    ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    useLatestZfsCompatibleKernel = true;
  };

  powerManagement.cpuFreqGovernor = "ondemand";
}
