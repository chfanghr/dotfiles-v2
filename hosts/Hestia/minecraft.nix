{
  lib,
  config,
  ...
}: let
  containerName = "minecraft";

  macVlanNic = "enp195s0";
  virtualNic = "mv-${macVlanNic}";

  monitoringVeth = "ve-mc";

  hostAddress = "172.16.0.1";
  localAddress = "172.16.0.3";
in {
  containers.${containerName} = {
    autoStart = true;

    privateNetwork = true;
    enableTun = true;
    macvlans = ["enp195s0"];
    extraVeths.${monitoringVeth} = {
      inherit hostAddress localAddress;
    };

    config = {
      networking = {
        enableIPv6 = true;
        useNetworkd = true;
        interfaces.${virtualNic}.useDHCP = true;
        useHostResolvConf = lib.mkForce false;
        firewall = {
          enable = true;
          interfaces.${monitoringVeth}.allowedTCPPorts = [
            config.services.prometheus.exporters.node.port
          ];
        };
      };

      services = {
        resolved.enable = true;
        tailscale.enable = true;

        prometheus.exporters.node = {
          enable = true;
          listenAddress = localAddress;
        };
      };

      systemd.network = {
        wait-online.ignoredInterfaces = [virtualNic];
        networks."40-${virtualNic}".networkConfig.IPv6AcceptRA = true;
      };

      time.timeZone = "Asia/Hong_Kong";

      system.stateVersion = "24.11";
    };
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "${config.networking.hostName}-minecraft-node";
      static_configs = [
        {
          targets = [
            "${localAddress}:${toString config.containers.${containerName}.config.services.prometheus.exporters.node.port}"
          ];
          labels.instance = "${config.networking.hostName}-minecraft";
        }
      ];
    }
  ];
}
