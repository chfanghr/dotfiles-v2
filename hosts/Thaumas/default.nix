{
  inputs,
  secrets,
  config,
  ...
}: let
  wirelessPasswordSecret = "wirelessPassword";
in {
  imports = [
    ./turntable-relay.nix
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ../../modules/nixos/common
  ];

  dotfiles = {
    shared.props.locationName = "sg";
    nixos = {
      props = {
        hardware = {
          cpu.aarch64 = true;
          audio = true;
        };
        nix.roles.consumer = true;
        users.rootAccess = true;
      };
      # avahi
      networking.lanInterfaces = ["wlan0"];
    };
  };

  networking = {
    hostName = "Thaumas";

    useNetworkd = true;
    useDHCP = true;

    wireless = {
      enable = true;
      secretsFile = config.age.secrets.${wirelessPasswordSecret}.path;
      networks.colon_o = {
        ssid = ":O";
        pskRaw = "ext:psk_colon_o";
      };
    };
  };

  users.users = {
    fanghr.hashedPassword = "$y$j9T$uVPyFPucql3Wsc0oeCT1d/$FEiyi5p3V0vJWh5dSgbYFrOcs2oEENSHqkIKBt09Wa5";
    root.hashedPassword = "$y$j9T$GHyMPPPxtPp0bKMVzStS2/$nm.k/kZzZZZlkRpL.QSk8Fh7wVqa2cM3q/zudzUrpa3";
  };

  hardware.raspberry-pi.firmware = {
    enable = true;
    uboot.enable = true;
    useGenerationDeviceTree = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-id/mmc-EZSD1_0xaa000971-part2";
      fsType = "ext4";
    };
    "/boot/firmware" = {
      device = "/dev/disk/by-id/mmc-EZSD1_0xaa000971-part1";
      fsType = "vfat";
      options = ["umask=0077"];
    };
  };

  age = {
    identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    secrets.${wirelessPasswordSecret} = {
      owner = "wpa_supplicant";
      group = "wpa_supplicant";
      mode = "0440";
      file = "${secrets}/thaumas-wireless-conf.age";
    };
  };

  services.smartd.enable = false;
}
