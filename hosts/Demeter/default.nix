{lib, ...}: {
  imports = [
    ./boot.nix
    ./cardano.nix
    ./file-systems.nix
    ./grafana.nix
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
          cpu.intel = true;
          gpu.amd.enable = true;
          emulation = true;
          rgb = true;
          vmHost = true;
        };
        nix.roles.builder = true;
        users.guests.thungghuan = true;
        ociHost = true;
      };
      networking.lanInterfaces = ["enp81s0"];
    };
  };

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  home-manager.users.fanghr.dotfiles.hm.graphical.desktop.hyprland.extraConfig = ''
    monitor=DP-1,3840x2160@120,0x0,2
  '';

  users.users.fanghr.hashedPassword = "$y$j9T$q3G6zE9QU2YXOxG2wLqCW1$DDWbED5h2fXtgNev2MtNhkNXFPzayP7w8O9HCLlx3Y5";

  specialisation.debug.configuration = {
    boot = {
      loader.systemd-boot.memtest86.enable = true;
      plymouth.enable = false;
    };

    dotfiles.shared.props.purposes.graphical.desktop = false;
  };
}
