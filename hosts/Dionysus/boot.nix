{
  pkgs,
  config,
  lib,
  ...
}: let
  # HACK: fix xhci_pci missing
  modulesTree = let
    inherit (config.boot.kernelPackages) kernel;
  in [
    (lib.getOutput "modules" kernel)
  ];
in {
  system = {inherit modulesTree;};

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;

    kernelParams = ["microcode.amd_sha_check=off"];

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    loader = {
      systemd-boot.enable = false; # Handled by lanzaboote
      efi.canTouchEfiVariables = true;
    };

    extraModulePackages = [
      config.boot.kernelPackages.zenergy
      config.boot.kernelPackages.universal-pidff
    ];

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "i40e"
      ];
      kernelModules = [
        "dm-snapshot"
        "dm-crypt"
        "vfat"
        "nls_cp437"
        "nls_iso8859-1"
        "usbhid"
        "r8169"
        "zenergy"
      ];
      network = {
        enable = true;
        # TODO: enable ssh unlock
      };
      systemd = {
        enable = true;
        network.enable = true;
      };
    };
  };

  environment.defaultPackages = [
    pkgs.sbctl
  ];

  specialisation.nvidia-latest.configuration = {config, ...}: {
    boot.kernelPackages = config.dotfiles.shared.nixpkgs-unstable.pkgs.linuxPackages_latest;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
