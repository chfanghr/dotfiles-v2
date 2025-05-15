{inputs, ...}: {
  imports = [
    ./boot.nix
    ./disko.nix
    ./impermanence.nix
    ../../modules/nixos/common
    inputs.disko.nixosModules.default
    inputs.impermanence.nixosModules.default
  ];

  dotfiles.nixos.props = {
    hardware = {
      cpu.intel = true;
      vmHost = true;
    };
    nix.roles.consumer = true;
    ociHost = true;
  };

  networking = {
    hostName = "Eros";

    enableIPv6 = true;

    useDHCP = true;

    nftables.enable = true;
    firewall.enable = true;
  };

  services = {
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
    lldpd.enable = true;
  };

  time.timeZone = "Asia/Hong_Kong";

  users.users.fanghr.hashedPassword = "$y$j9T$zOPTGKuw0I7uCBkW1Y3pV1$cm7EDph6molwLwx2iGrD2frPvADEzExs7jwDQaCVOn0";
}
