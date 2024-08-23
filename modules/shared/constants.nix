{
  dotfiles.shared = {
    networking.home.router = {
      address = "10.41.0.1";
    };
    networking.home.gateway = {
      address = "10.41.255.251";
      proxyPorts = {
        http = 1086;
        socks5 = 1087;
      };
    };
  };
}
