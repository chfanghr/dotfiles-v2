{lib, ...}: {
  imports = [
    ./boot.nix
    ./cardano.nix
    ./file-systems.nix
    ./grafana.nix
    ./minecraft.nix
    ./prometheus.nix
    ./security.nix
    ./traefik.nix
    ../../modules/nixos/common
  ];

  networking.hostName = "Demeter";

  services.hardware.openrgb.motherboard = "amd";

  dotfiles = {
    shared.props = {
      purposes = {
        work = true;
        graphical.desktop = lib.mkDefault true;
      };
      networking.home = {
        onLanNetwork = true;
        proxy.useRouter = true;
      };
    };
    nixos = {
      props = {
        hardware = {
          audio = true;
          bluetooth = {
            enable = true;
            blueman = true;
          };
          cpu.amd = true;
          gpu.amd.enable = true;
          emulation = true;
          rgb = true;
          vmHost = true;
        };
        nix.roles.builder = true;
        users.guests = {
          thungghuan = true;
          robertchen = true;
        };
        ociHost = true;
      };
      networking.lanInterfaces = ["enp81s0"];
    };
  };

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  home-manager.users.fanghr = {
    dotfiles.hm.graphical.desktop.hyprland.extraConfig = ''
      monitor=DP-1,3840x2160@120,0x0,2
    '';
    programs.git.signing = {
      key = "0x06DA3273BC714AE7";
      signByDefault = true;
    };
  };

  users.users = {
    fanghr = {
      hashedPassword = "$y$j9T$q3G6zE9QU2YXOxG2wLqCW1$DDWbED5h2fXtgNev2MtNhkNXFPzayP7w8O9HCLlx3Y5";
      extraGroups = ["cardano-node" "minecraft"];
    };
    robertchen.extraGroups = ["minecraft"];
    szg251 = {
      isNormalUser = true;
      createHome = true;
      extraGroups = ["cardano-node" "docker"];
      home = "/home/szg251";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8SiZHctbdcQhuteXYuO1Yw4XgM/fO3QDTYKyyA4UKj"
      ];
    };
  };

  programs.mosh.enable = true;

  specialisation.debug.configuration = {
    boot = {
      loader.systemd-boot.memtest86.enable = true;
      plymouth.enable = false;
    };

    dotfiles.shared.props.purposes.graphical.desktop = false;
  };
}
