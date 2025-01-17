{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./disko.nix
    ./fry.nix
    ./samba.nix
    ./tank.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
    inputs.agenix.nixosModules.default
  ];

  dotfiles.nixos.props = {
    nix.roles.consumer = true;
    users.fanghr.disableHm = true;
    hardware.cpu.intel = true;
  };

  time.timeZone = "Asia/Hong_Kong";

  users.users.fanghr.hashedPassword = "$y$j9T$tn5fAVwNCepbQ4xrimozH0$FhC1TMwwwcKFfDFtX4qx23AUhHRee9o2GviL5dM35b.";

  boot = {
    initrd.availableKernelModules = [
      "sdhci_pci"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "nvme"
      "r8169"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems.zfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  nix.gc.options = "--delete-older-than +8";

  networking = {
    hostName = "Artemis";
    useNetworkd = true;
    nftables.enable = true;
    hostId = "f12cb296";
  };

  environment.defaultPackages = [
    pkgs.zellij
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  powerManagement.cpuFreqGovernor = "ondemand";

  services = {
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
    lldpd.enable = true;
  };
}
