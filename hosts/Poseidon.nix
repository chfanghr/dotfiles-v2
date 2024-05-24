{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../modules/nixos/common
  ];

  networking.hostName = "Poseidon";

  dotfiles = {
    props = [
      "is-nix-builder"
      "is-nix-consumer"
      "is-on-lan"
      "has-bluetooth"
      "needs-blueman"
      "has-audio"
      "is-container-host"
      "runs-vscode-code-server"
      "is-graphical"
      "is-for-gaming"
      "uses-yubikey"
      "has-nvidia-gpu"
      "has-intel-cpu"
      "has-wireless"
    ];

    hardware.nvidia.driver = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "555.42.02";
      sha256_64bit = "sha256-k7cI3ZDlKp4mT46jMkLaIrc2YUx1lh1wj/J4SVSHWyk=";
      sha256_aarch64 = "sha256-ekx0s0LRxxTBoqOzpcBhEKIj/JnuRCSSHjtwng9qAc0=";
      openSha256 = "sha256-3/eI1VsBzuZ3Y6RZmt3Q5HrzI2saPTqUNs6zPh5zy6w=";
      settingsSha256 = "sha256-rtDxQjClJ+gyrCLvdZlT56YyHQ4sbaL+d5tL4L4VfkA=";
      persistencedSha256 = "sha256-3ae31/egyMKpqtGEqgtikWcwMwfcqMv2K4MVFa70Bqs=";
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

  services.udev = {
    packages = [
      pkgs.yubikey-personalization
      pkgs.libu2f-host
    ];

    extraRules = ''
      # QinHeng Electronics CH340 serial converter
      ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE:="0660", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
    '';
  };

  users.users.fanghr.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoVXyX0kHBZLz1MDvsLS2Ei/l+7Vm84vMyqgEtL6EhH fanghr@Demeter"
  ];
}
