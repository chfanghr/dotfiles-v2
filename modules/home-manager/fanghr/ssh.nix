{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkMerge [
  {
    programs.ssh.enable = true;
  }
  (lib.mkIf config.dotfiles.shared.props.networking.home.proxy.useGateway {
    programs.ssh.matchBlocks = let
      inherit (config.dotfiles.shared.networking.home) gateway;
      proxyCommand = "${lib.getExe' pkgs.netcat "nc"} -X 5 -x ${gateway.address}:${builtins.toString gateway.proxyPorts.socks5} %h %p";
    in {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        inherit proxyCommand;
      };
      "gist.github.com" = {
        hostname = "github.com";
        user = "git";
        inherit proxyCommand;
      };
      "*.staging.mlabs.city" = {
        inherit proxyCommand;
      };
    };
  })
]
