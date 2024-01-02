{pkgs, ...}: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.binfmt.emulatedSystems = [
    "x86_64-windows"
    "aarch64-linux"
  ];

  networking = {
    hostName = "Demeter";
    networkmanager.enable = false;
    useNetworkd = true;
    proxy = {
      default = "http://10.42.0.1:1086";
      httpProxy = "http://10.42.0.1:1086";
      httpsProxy = "http://10.42.0.1:1086";
    };
    firewall = {
      enable = true;
    };
  };

  systemd.network.wait-online.extraArgs = ["-i" "enp81s0"];

  time.timeZone = "Asia/Hong_Kong";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.fanghr = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJnZjDdWnD6KdkEzCW2lZ3Zg7hSYtRYdRPoGJWuR3fJB5ZOYP/zAzGkJ+GngoBc2TAK6hGcZmP3ScLVXb6a12eLrqpNFuq4Ja0zDI+QhItr7WxgeXZcdnrgu8bZ7j70z+PrJq9ZzUVWG3EnnOkRpHG1NC45Bi7Y/sp7gQXrTYxOnq4Hvo4CeUdVno/ImmTgg63IW4qJYUJ+YidiUo5rslwFiVS8XgTJkI1zswvIkurQhWTUoX+nj/Oo7f1w41dwkbjXun44bXQIJO6jrKf8KY9gM1dIwK+pNWYOql/vnItsohlx7CwclwyJl4xcj/21gWgh8AXuJ+kWPPUnm2DrAnbDN2W/8kboa7DpFrg5oiDaLU9Q3n1abIBraujhY3pHEg8DYhLB4zqblHlUB2GmaZ9SkfDZyJ01CTuSUJHY/a3duGQGEBXOgWV32F9G5DcUHVr996/I4EMIuPFAbxMA7p4dO4i26y3mg/E6lIzMEGxy38Fg/0PVUEsI5tk6vIbPrI+AkDWIBjQwFodQaC1elXSFcwVD+Fx8bCQk2coFhO8fG1yr41AH3ZRg8i5MmaTSu49Pqj3wVRJs2NJKkh4Cm0LFJqmb6ReYK0KOqB/hLCXSYhrBmmS4/hwhqPZ3GRkzHWvwVk14yeDoLW7TchCr3L4a87jnXp3mkNnVGGwGgacMQ== cardno:19 342 978"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErEFbKgAG7yvw8MlrwtZ6M4/VrBrPTenxKcHEpjF1XH chfanghr@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK39RaEP0hXf6IiC2GPgxBAX6H4F6apkfEVY11ZeZNy7 fanghr@bruh"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$QNGF492EVUDRotin.hBJA.$S0UY7FJKfDiAxmAg6hciTiiyVvEoUgSlhiHFWHvkz.7";
  };

  nix = {
    gc.automatic = true;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
      keep-outputs = true
      keep-derivations = true
    '';
    settings = {
      trusted-users = [
        "root"
        "fanghr"
      ];
      substituters = [
        "https://cache.nixos.org?priority=1"
        "https://nix-community.cachix.org?priority=2"
        "https://iohk.cachix.org?priority=999"
      ];
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      ];
    };
  };

  services = {
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        workstation = true;
        hinfo = true;
        domain = true;
        addresses = true;
      };
      extraServiceFiles = {
        ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
        sftp = "${pkgs.avahi}/etc/avahi/services/sftp-ssh.service";
      };
    };

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        X11Forwarding = true;
      };
    };

    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
  };

  systemd.services.successBootIndication = {
    script = "sleep 10; ${pkgs.openrgb}/bin/openrgb -d 0 -c 4169E1 -m static -b 50";
    wantedBy = ["openrgb.service"];
    serviceConfig.Type = "oneshot";
  };

  environment.systemPackages = with pkgs; [
    curl
    btop
    coreutils
    file
    openrgb
  ];

  programs = {
    zsh = {
      enable = true;
      enableBashCompletion = true;
    };
    git.enable = true;
    neovim = {
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };
    tmux = {
      enable = true;
    };
  };

  # virtualisation.docker.enable = true;
  # virtualisation.docker.storageDriver = "btrfs";

  virtualisation.podman = {
    enable = true;
    # networkSocket.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {dns_enabled = true;};
  };

  services.tailscale.enable = true;

  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;

  # services.vscode-server.enable = true;

  system.stateVersion = "23.11";
}
