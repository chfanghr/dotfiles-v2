{lib, ...}: {
  imports = [
    ./disko.nix
    ../../modules/nixos/common
    ../../modules/nixos/steamdeck
  ];

  networking.hostName = "Uranus";

  dotfiles = {
    shared.props = {
      locationName = "mars";
      purposes.graphical = {
        gaming = true;
        desktop = true;
      };
      hardware.steamdeck = true;
    };
    nixos.props = {
      hardware.bluetooth.enable = true;
      nix.roles.consumer = true;
      users.rootAccess = true;
      services.prometheus.pushToCollector = false;
    };
  };

  users.users = {
    fanghr.hashedPassword = "$y$j9T$tn5fAVwNCepbQ4xrimozH0$FhC1TMwwwcKFfDFtX4qx23AUhHRee9o2GviL5dM35b.";
    root.hashedPassword = "$y$j9T$LclEAQG.FK8eoV2.mc6ku1$dDc7MUikq2gi7Jpbo4AeQsnkdUjEFsfJ0XbhMY3yedA";
  };

  services.desktopManager.plasma6.enable = true;
  jovian.steam.desktopSession = lib.mkForce "plasma";
}
