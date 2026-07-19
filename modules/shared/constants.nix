{
  dotfiles.shared = {
    locations = {
      cn-1 = {
        timeZone = "Asia/Hong_Kong";
        networking.lan.ipv4 = {
          prefixLength = 16;
          router.address = "10.41.0.1";
          gfwBypass = {
            gateway.address = "10.41.0.2";
            proxy = {
              address = "10.41.0.3";
              http.port = 1086;
              socks5.port = 1087;
            };
          };
        };
        prometheus = "https://persephone.snow-dace.ts.net/prometheus/write";
      };

      cn-2 = {
        timeZone = "Asia/Hong_Kong";
        networking.lan.ipv4 = {
          prefixLength = 16;
          router.address = "10.31.0.1";
          gfwBypass.gateway.address = "10.31.0.100";
        };
        prometheus = "https://persephone.snow-dace.ts.net/prometheus/write";
      };

      sg = {
        timeZone = "Asia/Singapore";
        networking.lan.ipv4 = {
          prefixLength = 16;
          router.address = "10.10.0.1";
        };
        prometheus = "https://apollo.snow-dace.ts.net/prometheus/write";
      };

      mars.prometheus = "https://apollo.snow-dace.ts.net/prometheus/write";
    };
  };
}
