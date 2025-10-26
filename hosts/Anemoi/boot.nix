{config, ...}: {
  boot = {
    useLatestZfsCompatibleKernel = true;

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "iwlwifi"
      ];

      kernelModules = [
        "dm-snapshot"
        "dm-crypt"
        "vfat"
        "nls_cp437"
        "nls_iso8859-1"
        "usbhid"
        "r8169"
      ];

      network = {
        enable = true;

        ssh = {
          enable = true;

          port = 2222;

          hostKeys = [
            "/etc/secrets/initrd/ssh_host_rsa_key"
            "/etc/secrets/initrd/ssh_host_ed25519_key"
          ];

          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK39RaEP0hXf6IiC2GPgxBAX6H4F6apkfEVY11ZeZNy7"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJnZjDdWnD6KdkEzCW2lZ3Zg7hSYtRYdRPoGJWuR3fJB5ZOYP/zAzGkJ+GngoBc2TAK6hGcZmP3ScLVXb6a12eLrqpNFuq4Ja0zDI+QhItr7WxgeXZcdnrgu8bZ7j70z+PrJq9ZzUVWG3EnnOkRpHG1NC45Bi7Y/sp7gQXrTYxOnq4Hvo4CeUdVno/ImmTgg63IW4qJYUJ+YidiUo5rslwFiVS8XgTJkI1zswvIkurQhWTUoX+nj/Oo7f1w41dwkbjXun44bXQIJO6jrKf8KY9gM1dIwK+pNWYOql/vnItsohlx7CwclwyJl4xcj/21gWgh8AXuJ+kWPPUnm2DrAnbDN2W/8kboa7DpFrg5oiDaLU9Q3n1abIBraujhY3pHEg8DYhLB4zqblHlUB2GmaZ9SkfDZyJ01CTuSUJHY/a3duGQGEBXOgWV32F9G5DcUHVr996/I4EMIuPFAbxMA7p4dO4i26y3mg/E6lIzMEGxy38Fg/0PVUEsI5tk6vIbPrI+AkDWIBjQwFodQaC1elXSFcwVD+Fx8bCQk2coFhO8fG1yr41AH3ZRg8i5MmaTSu49Pqj3wVRJs2NJKkh4Cm0LFJqmb6ReYK0KOqB/hLCXSYhrBmmS4/hwhqPZ3GRkzHWvwVk14yeDoLW7TchCr3L4a87jnXp3mkNnVGGwGgacMQ=="
          ];
        };
      };

      systemd = {
        enable = true;
        network.enable = true;
        emergencyAccess = "$y$j9T$U7QyEy3Eof9kDEU.gngEK1$2aiuJWRMbBSrKuUf9vEFD7lQUzy3CqdNFxl9SnmNra1";

        services.zfs-remote-unlock = {
          wantedBy = ["initrd.target"];
          after = ["systemd-networkd.service"];
          path = [config.boot.zfs.package]; # Is this really needed??
          serviceConfig.Type = "oneshot";
          script = ''
            echo "systemctl default" >> /var/empty/.profile
          '';
        };
      };
    };

    loader = {
      systemd-boot = {
        enable = true;
      };
      efi.canTouchEfiVariables = true;
    };

    plymouth.enable = false;

    binfmt.emulatedSystems = [
      "aarch64-linux"
    ];
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
