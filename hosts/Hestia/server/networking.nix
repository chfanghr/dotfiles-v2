{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types concatStringsSep mkEnableOption;
  cfg = config.hestia.server.networking;
in {
  options.hestia.server.networking = {
    enable = mkEnableOption "server mode networking setup";

    lanBridge = {
      interface = mkOption {type = types.str;};
      netdevProfile = mkOption {type = types.str;};
      networkProfile = mkOption {type = types.str;};

      slave = {
        interfaces = mkOption {type = types.nonEmptyListOf types.str;};
        networkProfile = mkOption {type = types.str;};
      };

      dummy = {
        interface = mkOption {type = types.str;};
        netdevProfile = mkOption {type = types.str;};
        networkProfile = mkOption {type = types.str;};
      };
    };
    ap = {
      device = mkOption {type = types.str;};

      ssid = mkOption {type = types.str;};

      encryptedPasswordFile = mkOption {type = types.pathInStore;};
    };
  };

  config = mkIf cfg.enable {
    networking.useNetworkd = true;

    systemd.network = {
      netdevs = {
        ${cfg.lanBridge.netdevProfile} = {
          netdevConfig = {
            Kind = "bridge";
            Name = cfg.lanBridge.interface;
          };
          bridgeConfig.STP = true;
        };
        ${cfg.lanBridge.dummy.netdevProfile}.netdevConfig = {
          Kind = "dummy";
          Name = cfg.lanBridge.dummy.interface;
        };
      };

      networks = {
        ${cfg.lanBridge.networkProfile} = {
          matchConfig.Name = cfg.lanBridge.interface;
          networkConfig = {
            DHCP = "ipv4";
            IPv4Forwarding = "yes";
            IPv6Forwarding = "yes";
            IPv6AcceptRA = true;
          };
          bridgeConfig.UseBPDU = true;
        };
        ${cfg.lanBridge.slave.networkProfile} = {
          matchConfig.Name = concatStringsSep " " cfg.lanBridge.slave.interfaces;
          networkConfig.Bridge = cfg.lanBridge.interface;
          linkConfig.RequiredForOnline = "enslaved";
        };
        ${cfg.lanBridge.dummy.networkProfile} = {
          matchConfig.Name = cfg.lanBridge.dummy.interface;
          networkConfig.Bridge = cfg.lanBridge.interface;
        };
      };
    };

    age.secrets.ap-password.file = cfg.ap.encryptedPasswordFile;

    services.hostapd = {
      enable = true;

      radios.${cfg.ap.device} = {
        band = "5g";
        channel = 149;
        countryCode = "CN";

        wifi4.enable = true;
        wifi5.enable = true;
        wifi6 = {
          enable = true;
          multiUserBeamformer = true;
          singleUserBeamformer = true;
        };
        wifi7 = {
          enable = true;
          multiUserBeamformer = true;
          singleUserBeamformer = true;
        };

        networks.${cfg.ap.device} = {
          ssid = cfg.ap.ssid;
          logLevel = 0;
          authentication = {
            enableRecommendedPairwiseCiphers = true;
            pairwiseCiphers = [
              "CCMP-256"
              "GCMP-256"
            ];
            saePasswordsFile = config.age.secrets.ap-password.path;
          };
          settings.bridge = cfg.lanBridge.interface;
        };
      };
    };

    systemd.services.hostapd.bindsTo = [
      "sys-devices-virtual-net-${cfg.lanBridge.interface}.device"
    ];
  };
}
