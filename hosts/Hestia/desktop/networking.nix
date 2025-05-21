{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.hestia.desktop.networking;
in {
  options.hestia.desktop.networking = {
    lanBridge = {
      interface = mkOption {type = types.str;};

      slave.interfaces = mkOption {type = types.nonEmptyListOf types.str;};
    };
  };

  config = mkIf (config.hestia.mode == "desktop") {
    networking = {
      useNetworkd = false;

      bridges.${cfg.lanBridge.interface}.interfaces =
        cfg.lanBridge.slave.interfaces;

      interfaces.${cfg.lanBridge.interface}.useDHCP = true;
    };
  };
}
