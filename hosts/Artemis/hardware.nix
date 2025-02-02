{pkgs, ...}: {
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
    supportedFilesystems.zfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["nohibernate"];
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  services.zfs.autoScrub.enable = true;

  networking.hostId = "networking";
}
