{config, ...}: {
  boot = {
    useLatestZfsCompatibleKernel = true;

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
        "igc"
      ];

      systemd = {
        enable = true;

        services.rollback = {
          description = "Rollback root filesystem to a pristine state";
          wantedBy = ["initrd.target"];
          after = ["zfs-import-rpool.service"];
          before = ["sysroot.mount"];
          path = [config.boot.zfs.package];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            zfs rollback -r rpool/root@blank && echo " >> >> Rollback Complete << <<"
          '';
        };
      };
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  powerManagement.cpuFreqGovernor = "performance";
}
