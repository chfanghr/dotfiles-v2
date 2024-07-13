{lib, ...}: {
  imports = [
    ../../modules/nixos/common
    ./boot.nix
    ./dlna.nix
    ./networking.nix
    ./qbittorrent.nix
    ./root-fs.nix
    ./samba.nix
    ./tank.nix
    ./yotsuba.nix
  ];

  networking.hostName = "Artemis";

  dotfiles = {
    shared.props.networking.home = {
      onLanNetwork = true;
      proxy.useRouter = true;
    };
    nixos.props = {
      hardware = {
        cpu.intel = true;
        vmHost = true;
      };
      nix.roles.consumer = true;
    };
  };

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  users.users.fanghr = {
    hashedPassword = "$y$j9T$da6fRvhfh8tQZ9.SbLCd60$uS50OnQww4mXqjkZEA5aQlAsZMs4/Q/gu48.y6sxLq/";
  };

  services.openssh.hostKeys = [
    {
      bits = 4096;
      path = "/etc/secrets/ssh/ssh_host_rsa_key";
      type = "rsa";
    }
    {
      path = "/etc/secrets/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  system.stateVersion = lib.mkForce "22.11";
}
