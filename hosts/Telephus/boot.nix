{
  boot = {
    initrd.availableKernelModules = ["nvme" "virtio_pci" "xhci_pci" "usbhid" "usb_storage"];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
