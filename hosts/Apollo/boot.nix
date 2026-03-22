{
  config,
  pkgs,
  ...
}: let
  initrdHostKey = "/etc/secrets/initrd/ssh_host_ed25519_key";
in {
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

    supportedFilesystems = {
      btrfs = true;
    };

    useLatestZfsCompatibleKernel = true;

    initrd = {
      secrets = {
        ${initrdHostKey} = initrdHostKey;
      };

      network = {
        enable = true;

        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [initrdHostKey];
          authorizedKeys = config.users.users.fanghr.openssh.authorizedKeys.keys;
        };
      };

      systemd = {
        network.enable = true;
        enable = true;

        contents."/etc/hostname".text = "${config.networking.hostName}-boot";

        emergencyAccess = "$y$j9T$2TSgVktAmtPlsD0fimxXw0$iqLvWrUDnzGIpnA6xDUaUi1Yd4i5PvCkcIPXHEFIwI3";

        services = {
          setup-remote-unlock = {
            description = "Prepare for ZFS remote unlock";
            wantedBy = ["initrd.target"];
            after = ["systemd-networkd.service"];
            serviceConfig.Type = "oneshot";
            script = ''
              echo "systemctl default" >> /var/empty/.profile
            '';
          };
          rollback-rootfs = {
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
  };

  powerManagement.cpuFreqGovernor = "performance";

  environment.defaultPackages = [pkgs.sbctl];
}
