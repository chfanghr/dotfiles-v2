{
  config,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [
        "dm-snapshot"
        "dm-crypt"
        "vfat"
        "nls_cp437"
        "nls_iso8859-1"
        "usbhid"
        # "r8169"
        "igc"
        "i2c-dev"
        "i2c-piix4"
      ];
      network = {
        enable = true;
        udhcpc = {
          enable = true;
          extraArgs = ["-t" "20"];
        };
        ssh = {
          enable = true;
          authorizedKeys = config.users.users.fanghr.openssh.authorizedKeys.keys;
          hostKeys = [
            "/etc/secrets/initrd/ssh_host_ed25519_key"
          ];
        };
      };
      luks = {
        yubikeySupport = true;
        devices = {
          enc = {
            allowDiscards = true;
            device = "/dev/nvme0n1p2";
            preLVM = false;
            yubikey = {
              slot = 2;
              twoFactor = false;
              storage.device = "/dev/nvme0n1p1";
            };
          };
        };
      };
    };
  };

  systemd.services.successBootIndication = {
    script = "sleep 10; ${config.services.hardware.openrgb.package}/bin/openrgb -d 0 -c 4169E1 -m static -b 50";
    wantedBy = ["multi-user.target"];
    after = ["openrgb.service"];
    serviceConfig.Type = "oneshot";
  };

  services.ucodenix.enable = true;
}
