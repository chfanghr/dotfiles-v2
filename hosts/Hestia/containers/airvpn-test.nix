{
  lib,
  pkgs,
  config,
  ...
}: let
  lanInterface = "ve-av-lan";
  secretDir = "/secrets";
in {
  age.secrets = {
    wg-peer-preshared-key.file = ../../../secrets/hestia-wg-av-peer.age;
    wg-private-key.file = ../../../secrets/hestia-wg-av-private.age;
  };

  containers.av-test = {
    autoStart = false;
    ephemeral = true;

    additionalCapabilities = [
      "CAP_NET_ADMIN"
      "CAP_MKNOD"
    ];

    privateNetwork = true;
    extraVeths.${lanInterface}.hostBridge = "br0";

    bindMounts = {
      "${secretDir}/wg-peer-preshared-key".hostPath = config.age.secrets.wg-peer-preshared-key.path;
      "${secretDir}/wg-private-key".hostPath = config.age.secrets.wg-private-key.path;
    };

    config = {
      networking = {
        enableIPv6 = true;
        useNetworkd = true;
        interfaces.${lanInterface}.useDHCP = true;
        useHostResolvConf = lib.mkForce false;
        firewall.enable = true;
        nftables.enable = true;

        wireguard = {
          interfaces.av = {
            allowedIPsAsRoutes = false;

            ips = [
              "10.165.180.142/32"
              "fd7d:76ee:e68f:a993:fecc:33a4:6831:39/128"
            ];

            mtu = 1320;

            privateKeyFile = "/secrets/wg-private-key";

            peers = [
              {
                allowedIPs = [
                  "0.0.0.0/0"
                  "::/0"
                ];
                endpoint = "nl3.vpn.airdns.org:1637";
                publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
                presharedKeyFile = "/secrets/wg-peer-preshared-key";
                persistentKeepalive = 15;
              }
            ];
          };
        };
      };

      services.resolved.enable = true;

      time.timeZone = "Asia/Hong_Kong";

      environment.systemPackages = with pkgs; [dig];

      system.stateVersion = "25.05";
    };
  };
}
