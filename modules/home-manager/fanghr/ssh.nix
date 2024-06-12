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
  (lib.mkIf config.dotfiles.shared.props.networking.home.proxy.useRouter {
    programs.ssh.matchBlocks = let
      inherit (config.dotfiles.shared.networking.home) router;
      proxyCommand = "${lib.getExe' pkgs.netcat "nc"} -X 5 -x ${router.address}:${builtins.toString router.proxyPorts.socks5} %h %p";
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
