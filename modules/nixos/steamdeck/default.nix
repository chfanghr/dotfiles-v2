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
    ./decky.nix
  ];

  nixpkgs.localSystem.system = "x86_64-linux";

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

  jovian.decky-loader = {
    enable = true;
    user = "fanghr";
    stateDir = "/home/fanghr/.local/share/decky";
    extraPackages = with pkgs; [
      curl
      unzip
      util-linux
      gnugrep

      readline.out
      procps
      pciutils
      libpulseaudio

      python3
    ];

    extraPythonPackages = pythonPackages:
      with pythonPackages; [
        pyyaml # hhd-decky
      ];

    plugins = {
      "SDH-CssLoader" = {
        src = pkgs.fetchzip {
          url = "https://github.com/DeckThemes/SDH-CssLoader/releases/download/v2.1.1/SDH-CSSLoader-Decky.zip";
          sha256 = "sha256-ktjUEeW9pBSrmOrwsjcDE3SRlocd3KVdxkGR2AyB6O4=";
          extension = "zip";
          stripRoot = true;
        };
      };
    };

    themes = {
      "Switch Like Home" = {
        enable = true;
        src = pkgs.fetchzip {
          url = "https://api.deckthemes.com/blobs/3aa81edf-e2de-45c7-89fc-52277987ed50";
          sha256 = "sha256-VX4Y5vZfNChB4DX1w/Ro0e9vKymOOWGp7ZdhUwwoepc=";
          stripRoot = true;
          extension = "zip";
        };
        config = {
          "No Friends" = "No";
        };
      };
      "DellyVolume" = {
        enable = true;
        src = pkgs.fetchzip {
          url = "https://api.deckthemes.com/blobs/c7663cae-04a4-4409-886e-bdfdda8a8613";
          sha256 = "sha256-NaPQA3wEEG/uYcQqIaacLBE4KBlNrUAlb9nEiplGc94=";
          stripRoot = true;
          extension = "zip";
        };
        config = {};
      };
    };
  };

  system.activationScripts.prepareSteamForDeckyLoader = ''
    if [ -d /home/fanghr/.steam/steam/ ]; then
      FLAG=/home/fanghr/.steam/steam/.cef-enable-remote-debugging
      touch $FLAG
      chown fanghr: $FLAG
    fi
  '';
}
