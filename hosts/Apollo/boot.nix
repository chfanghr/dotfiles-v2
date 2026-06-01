{
  config,
  pkgs,
  lib,
  ...
}: let
  vars = import ./netvars.nix;

  inherit
    (vars)
    phyNetKey
    mainVlanNetKey
    mgmtVlanNetKey
    ;

  initrdHostKey = "/etc/secrets/initrd/ssh_host_ed25519_key";
  bootTimeHostName = "${config.networking.hostName}-boot";
  inherit (lib) recursiveUpdate;
in {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

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
      kernelModules = ["8021q"]; # VLAN

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
        enable = true;

        network = let
          stage2 = config.systemd.network;
        in {
          enable = true;

          netdevs = {
            "${mainVlanNetKey}" = stage2.netdevs.${mainVlanNetKey};
            "${mgmtVlanNetKey}" = stage2.netdevs.${mgmtVlanNetKey};
          };

          networks =
            recursiveUpdate {
              "${phyNetKey}" = stage2.networks.${phyNetKey};
              "${mainVlanNetKey}" = stage2.networks.${mainVlanNetKey};
              "${mgmtVlanNetKey}" = stage2.networks.${mgmtVlanNetKey};
            } {
              "${mainVlanNetKey}".dhcpV4Config.Hostname = bootTimeHostName;
            };
        };

        contents."/etc/hostname".text = bootTimeHostName;

        emergencyAccess = "$y$j9T$2TSgVktAmtPlsD0fimxXw0$iqLvWrUDnzGIpnA6xDUaUi1Yd4i5PvCkcIPXHEFIwI3";

        services = {
          setup-remote-unlock = {
            description = "Prepare for ZFS remote unlock";
            wantedBy = ["initrd.target"];
            after = ["systemd-networkd.service"];
            serviceConfig.Type = "oneshot";
            path = [config.boot.zfs.package];
            script = ''
              echo "systemd-tty-ask-password-agent --watch" >> /var/empty/.profile
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

  powerManagement = {
    cpuFreqGovernor = "performance";
    powertop.enable = true;
  };

  environment.defaultPackages = [pkgs.sbctl];
}
