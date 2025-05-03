{
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
      "igc" # enp1s0 enp3s0 enp4s0
      "r8152" # enp0s20f0u4
    ];

    kernelModules = ["kvm-intel"];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware.cpu.intel.updateMicrocode = true;

  powerManagement.cpuFreqGovernor = "performance";

  services = {
    btrfs.autoScrub.enable = true;
    fstrim.enable = true;
  };
}
