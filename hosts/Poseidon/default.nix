{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./minecraft.nix
    ./nfs.nix
    ../../modules/nixos/common
  ];

  networking.hostName = "Poseidon";

  dotfiles.nixos = {
    props = {
      hardware = {
        audio = true;
        bluetooth = {
          enable = true;
          blueman = true;
        };
        cpu.intel = true;
        emulation = true;
        rgb = true;
        vmHost = true;
      };
      nix.roles.consumer = true;
      users.guests.robertchen = true;
      ociHost = true;
    };
    networking.lanInterfaces = ["enp5s0"];
  };

  boot = {
    initrd = {
      availableKernelModules = [
        "vmd"
        "xhci_pci"
        "ahci"
        "nvme"
        "sd_mod"
      ];
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_zen;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a653f385-6f12-4622-9b59-b0350a307c11";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1C11-1151";
      fsType = "vfat";
    };
    "/mnt/storage" = {
      device = "/dev/disk/by-uuid/37b5c558-5dfc-4021-9556-9fec546275ec";
      fsType = "btrfs";
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/f72d4257-a1cb-407c-877d-2dbb720798c7";
    }
  ];

  programs.gnupg.agent = {
    enable = false;
    enableSSHSupport = true;
    enableExtraSocket = true;
  };

  services.udev.extraRules = ''
    # QinHeng Electronics CH340 serial converter
    ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE:="0660", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
  '';

  services.hardware.openrgb.motherboard = "intel";

  boot.loader.systemd-boot.consoleMode = "auto";

  users.users.fanghr.hashedPassword = "$y$j9T$ESoL30N/VpkRWrQjHtuJy0$xyvywylDt4YaLWg5KdqsZ5x2bSaRbGIRld811A4dBjA";

  time.timeZone = "Asia/Hong_Kong";

  dotfiles.shared.props.purposes.graphical = {
    gaming = lib.mkDefault true;
    desktop = lib.mkDefault true;
  };

  dotfiles.nixos.props.hardware.gpu.amd.enable = lib.mkDefault true;

  home-manager.users.fanghr.dotfiles.hm.graphical.desktop.hyprland.extraConfig = ''
    monitor=HDMI-A-1,3840x2160@120,0x0,2
  '';

  specialisation = {
    debug.configuration = {
      boot = {
        loader.systemd-boot.memtest86.enable = true;
        plymouth.enable = false;
      };

      dotfiles.shared.props.purposes.graphical = {
        gaming = false;
        desktop = false;
      };

      dotfiles.nixos.props.hardware.gpu.amd.enable = false;
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkForce "performance";
}
