{
  inputs,
  pkgs,
  ...
}: let
  apply_thp_tweaks = pkgs.writeShellScriptBin "apply_thp_tweaks" ''
    echo always > /sys/kernel/mm/transparent_hugepage/enabled
    echo 0 > /proc/sys/vm/compaction_proactiveness
    echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
    echo 1 > /proc/sys/vm/page_lock_unfairness
  '';
  undo_thp_tweaks = pkgs.writeShellScriptBin "undo_thp_tweaks" ''
    echo madvise > /sys/kernel/mm/transparent_hugepage/enabled
    echo 20 > /proc/sys/vm/compaction_proactiveness
    echo 1 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
    echo 5 > /proc/sys/vm/page_lock_unfairness
  '';
in {
  imports = [
    inputs.jovian.nixosModules.default
    inputs.disko.nixosModules.default
  ];

  boot = {
    plymouth.enable = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  jovian = {
    devices.steamdeck.enable = true;
    steam = {
      enable = true;
      autoStart = true;
      user = "fanghr";
      desktopSession = "hyprland";
    };
    decky-loader.enable = true;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    # "vm.nr_hugepages" = 1024; # double the amount of available huge pages
  };

  environment.systemPackages = [
    apply_thp_tweaks
    undo_thp_tweaks
    pkgs.steamdeck-firmware
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sdhci_pci"
  ];

  networking = {
    networkmanager.enable = true;
    useNetworkd = false;
    firewall = {
      allowedTCPPorts = [27036];
      allowedUDPPortRanges = [
        {
          from = 27031;
          to = 27036;
        }
      ];
    };
  };

  hardware.opengl.driSupport32Bit = true;
}
