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
      matchBlocks."*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };
  }
  (lib.mkIf config.dotfiles.shared.props.networking.home.proxy.useGateway {
    programs.ssh.matchBlocks = let
      inherit (config.dotfiles.shared.networking.home) gateway;
      proxyCommand = "${lib.getExe' pkgs.netcat "nc"} -X 5 -x ${gateway.address}:${builtins.toString gateway.proxyPorts.socks5} %h %p";
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
    };
  })
]
