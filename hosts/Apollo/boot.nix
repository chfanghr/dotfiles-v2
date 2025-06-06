{config, ...}: {
  boot = {
    kernelParams = ["i915.force_probe=4680"];

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    loader = {
      systemd-boot.enable = false; # secure boot with lanzaboote
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = {btrfs = true;};

    useLatestZfsCompatibleKernel = true;

    initrd = {
      availableKernelModules = [
        "i40e"
        "igc"
      ];

      systemd = {
        enable = true;

        emergencyAccess = "$y$j9T$2TSgVktAmtPlsD0fimxXw0$iqLvWrUDnzGIpnA6xDUaUi1Yd4i5PvCkcIPXHEFIwI3";

        services.rollback = {
          description = "Rollback root filesystem to a pristine state";
          wantedBy = ["initrd.target"];
          after = ["zfs-import-rpool.service"];
          before = ["sysroot.mount"];
          path = [config.boot.zfs.package];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            zfs rollback -r rpool/enc/root@blank && echo " >> >> Rollback Complete << <<"
          '';
        };
      };
    };
  };

  powerManagement.cpuFreqGovernor = "performance";
}
