{
  config,
  lib,
  ...
}: {
  imports = [
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

  specialisation = let
    graphicalModule = {
      dotfiles.shared.props.purposes.graphical = {
        gaming = true;
        desktop = true;
      };
    };
  in {
    debug.configuration = {
      boot = {
        loader.systemd-boot.memtest86.enable = true;
        plymouth.enable = false;
      };
    };

    nvidia_gpu.configuration = lib.mkMerge [
      graphicalModule
      {
        dotfiles.nixos.props.hardware.gpu.nvidia = true;

        nixpkgs.config.allowUnfree = true;

        hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "555.42.02";
          sha256_64bit = "sha256-k7cI3ZDlKp4mT46jMkLaIrc2YUx1lh1wj/J4SVSHWyk=";
          sha256_aarch64 = "sha256-ekx0s0LRxxTBoqOzpcBhEKIj/JnuRCSSHjtwng9qAc0=";
          openSha256 = "sha256-3/eI1VsBzuZ3Y6RZmt3Q5HrzI2saPTqUNs6zPh5zy6w=";
          settingsSha256 = "sha256-rtDxQjClJ+gyrCLvdZlT56YyHQ4sbaL+d5tL4L4VfkA=";
          persistencedSha256 = "sha256-3ae31/egyMKpqtGEqgtikWcwMwfcqMv2K4MVFa70Bqs=";
        };

        home-manager.users.fanghr.dotfiles.hm.graphical.desktop.hyprland.extraConfig = ''
          env = LIBVA_DRIVER_NAME,nvidia
          env = XDG_SESSION_TYPE,wayland
          env = GBM_BACKEND,nvidia-drm
          env = __GLX_VENDOR_LIBRARY_NAME,nvidia
          env = NVD_BACKEND,direct

          monitor=HDMI-A-2,3840x2160@100,0x0,1
        '';
      }
    ];

    amd_gpu.configuration = lib.mkMerge [
      graphicalModule
      {
        dotfiles.nixos.props.hardware.gpu.amd.enable = true;

        home-manager.users.fanghr.dotfiles.hm.graphical.desktop.hyprland.extraConfig = ''
          monitor=HDMI-A-1,3840x2160@120,0x0,2
        '';
      }
    ];
  };
}
