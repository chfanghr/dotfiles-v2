{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  pkgsUnstable = import inputs.nixpkgs-unstable {inherit (pkgs.stdenv) system;};
in {
  # HACK: fix xhci_pci missing
  system.modulesTree = let
    inherit (config.boot.kernelPackages) kernel;
  in [
    (lib.getOutput "modules" kernel)
  ];

  boot = {
    kernelPackages = pkgsUnstable.linuxPackages_zen;

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    loader = {
      systemd-boot.enable = false; # Handled by lanzaboote
      efi.canTouchEfiVariables = true;
    };

    plymouth.enable = false;

    extraModulePackages = [
      config.boot.kernelPackages.zenergy
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
}
