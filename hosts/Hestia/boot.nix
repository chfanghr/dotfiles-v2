{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce;

  initrdHostKey = "/etc/secrets/initrd/ssh_host_ed25519_key";
  bootTimeHostName = "${config.networking.hostName}-boot";
in {
  boot = {
    useLatestZfsCompatibleKernel = true;

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "mt7925e"
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
          hostKeys = [initrdHostKey];
          authorizedKeys = config.users.users.fanghr.openssh.authorizedKeys.keys;
        };
      };

      systemd = {
        enable = true;

        network = {
          enable = true;
          networks."40-enp195s0" = {
            matchConfig.Name = "enp195s0";
            networkConfig = {
              DHCP = mkForce "ipv4";
              IPv6AcceptRA = true;
              IPv6PrivacyExtensions = "kernel";
            };
            dhcpV4Config.Hostname = bootTimeHostName;
          };
        };

        contents."/etc/hostname".text = bootTimeHostName;

        services.setup-remote-unlock = {
          description = "Prepare for ZFS remote unlock";
          wantedBy = ["initrd.target"];
          before = ["initrd-root-fs.target"];
          serviceConfig.Type = "oneshot";
          unitConfig.DefaultDependencies = false;
          script = ''
            mkdir -p /var/empty
            echo "systemd-tty-ask-password-agent --watch" > /var/empty/.profile
          '';
        };
      };
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
    };

    plymouth.enable = false;

    binfmt.emulatedSystems = [
      "loongarch64-linux"
      "aarch64-linux"
    ];

    zfs.requestEncryptionCredentials = ["zp-mirrored/enc"];

    kernelModules = ["msr"];
  };

  environment.defaultPackages = [
    pkgs.sbctl
  ];

  services.hardware.bolt.enable = true;
}
