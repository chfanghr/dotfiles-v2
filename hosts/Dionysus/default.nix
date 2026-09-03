{
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./boot.nix
    ./disko.nix
    ../../modules/nixos/common
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.default
  ];

  networking.hostName = "Dionysus";

  dotfiles = {
    shared.props = {
      locationName = "sg";
      purposes = {
        work = true;
        graphical = {
          gaming = lib.mkDefault true;
          desktop = lib.mkDefault true;
        };
      };
    };
    nixos.props = {
      hardware = {
        audio = true;
        bluetooth = {
          enable = true;
          blueman = true;
        };
        cpu.amd = true;
        gpu.nvidia = true;
        gpu.amd.enable = true;
        emulation = true;
        vmHost = true;
      };
      nix.roles.consumer = true;
      ociHost = true;
    };
  };

  networking = {
    vlans = {
      "vlan-main" = {
        interface = "enp5s0f1np1";
        id = 42;
      };
      "vlan-mgmt" = {
        interface = "enp5s0f1np1";
        id = 120;
      };
    };
    interfaces = {
      "vlan-main".useDHCP = true;
      "vlan-mgmt" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "10.5.0.10";
            prefixLength = 16;
          }
        ];
      };
      "enp6s0f1np1".useDHCP = false;
    };
    firewall.trustedInterfaces = ["virbr0"];
  };

  users.users.fanghr.hashedPassword = "$y$j9T$SxmPzl.7ervjxa6Mzvq7p1$KLXfgvnEzCboA8TPWqGrEV/rn49v6uXiFSoIf7j5YGD";

  home-manager.users.fanghr.home.packages = [
    pkgs.handbrake
    pkgs.yacreader
    pkgs.chromium
  ];

  home-manager.users.fanghr.wayland.windowManager.niri.settings = {
    binds = {
      "Mod+F".fullscreen-window = {};
      "Mod+WheelScrollDown".focus-workspace-down = {};
      "Mod+WheelScrollUp".focus-workspace-up = {};
      "Mod+WheelScrollLeft" = {
        _props.cooldown-ms = 256;
        focus-column-left = {};
      };
      "Mod+WheelScrollRight" = {
        _props.cooldown-ms = 256;
        focus-column-right = {};
      };
      "Mod+Shift+Right".move-window-to-monitor-right = {};
      "Mod+Shift+Left".move-window-to-monitor-left = {};
    };

    _children = [
      {
        output = {
          _args = ["DP-3"];
          mode = "3840x2160@240.016";
          transform = "90";
          position._props = {
            x = 0;
            y = 0;
          };
          scale = 1.25;
        };
      }
      {
        output = {
          _args = ["DP-4"];
          mode = "3840x2160@240.016";
          focus-at-startup = {};
          position._props = {
            x = 1728;
            y = 672;
          };
          scale = 1.25;
          # variable-refresh-rate = {};
        };
      }
    ];
  };

  systemd.tmpfiles.settings."10-game-backup"."/data/game-backup".d = {
    user = "fanghr";
    mode = "0700";
  };

  programs = {
    steam = {
      protontricks.enable = true;
    };

    kdeconnect.enable = true;
  };

  services = {
    sunshine = {
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    xserver.displayManager.startx.enable = true;

    ucodenix.enable = true;

    iperf3 = {
      enable = true;
      openFirewall = true;
    };

    avahi = {
      enable = lib.mkForce true;
      allowInterfaces = [
        "vlan-main"
      ];
    };
  };

  environment.systemPackages = [
    pkgs.vulkan-tools
    pkgs.nvtopPackages.amd
    pkgs.boxflat
  ];

  services.udev.packages = [pkgs.boxflat];

  nix.settings = {
    download-buffer-size = 524288000;
    substituters = [
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  virtualisation.libvirtd.qemu.vhostUserPackages = [pkgs.virtiofsd];

  services.desktopManager.gnome.enable = true;

  specialisation = {
    debug.configuration = {
      dotfiles.shared.props.purposes.graphical = {
        desktop = false;
        gaming = false;
      };

      boot = {
        loader.systemd-boot.memtest86.enable = true;
        plymouth.enable = false;
      };

      networking.interfaces."enp6s0f0np0".useDHCP = true;
    };
  };
}
