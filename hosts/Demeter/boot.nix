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
        "bonding"
      ];
      network = {
        enable = true;
        ssh = {
          enable = true;
          authorizedKeys = config.users.users.fanghr.openssh.authorizedKeys.keys;
          hostKeys = [
            "/etc/secrets/initrd/ssh_host_ed25519_key"
          ];
        };
      };
      systemd.network.enable = true;
      luks = {
        devices = {
          enc = {
            allowDiscards = true;
            device = "/dev/nvme0n1p2";
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
