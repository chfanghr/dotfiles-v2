{
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["ntfs" "btrfs"];
    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
        "r8169"
      ];
      network = {
        enable = true;
        udhcpc.extraArgs = ["-t" "20"];
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = config.users.users.fanghr.openssh.authorizedKeys.keys;
          hostKeys = ["/etc/secrets/initrd/ssh/ssh_host_ed25519_key"];
        };
        postCommands = ''
          echo 'cryptsetup-askpass' >> /root/.profile
        '';
      };
    };
  };
}
