{
  dotfiles.shared = {
    networking.home.router = {
      address = "10.42.0.1";
      proxyPorts = {
        http = 1086;
        socks5 = 1087;
      };
    };
  };
}
