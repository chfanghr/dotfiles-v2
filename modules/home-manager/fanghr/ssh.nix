{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkMerge [
  {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
  }
  (lib.mkIf config.dotfiles.shared.props.networking.lan.ipv4.gfwBypass.useProxy {
    programs.ssh.matchBlocks = let
      inherit (config.dotfiles.shared.props.location.networking.lan.ipv4.gfwBypass) proxy;
      proxyCommand = "${lib.getExe' pkgs.netcat "nc"} -X 5 -x ${proxy.address}:${builtins.toString proxy.socks5.port} %h %p";
    in {
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        inherit proxyCommand;
      };
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
