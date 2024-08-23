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
    ./traefik.nix
    ./yotsuba.nix
  ];

  networking.hostName = "Artemis";

  dotfiles = {
    shared.props.networking.home = {
      onLanNetwork = true;
      proxy.useGateway = true;
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

  users.users.fanghr.hashedPassword = "$y$j9T$LXMnQ178S.dmirDdpF2ZF.$99/2fGfE5kMpaWlHXKWryIJhusvk1urp1GGJlN8Hlh3";

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

  nix.gc.options = "--delete-older-than +8";

  system.stateVersion = lib.mkForce "22.11";

  specialisation.noProxy.configuration = {
    dotfiles.shared.props.networking.home.proxy.useGateway = lib.mkForce false;
  };
}
