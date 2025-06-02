{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption types mkOption mkIf;

  cfg = config.services.prometheus.exporters.mktxp;

  routerConfigType = types.submodule ({name, ...}: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;
      };
    };
  });

  exporterConfigType = types.submodule {
    options = {};
  };
in {
  options.services.prometheus.exporters.mktxp = {
    enable = mkEnableOption "enable routeros metrics exporter mktxp";

    user = mkOption {type = types.str;};

    group = mkOption {type = types.str;};

    defaultConfig = mkOption {
      type = routerConfigType;
    };

    routerConfigs = mkOption {
      type = routerConfigType;
    };

    exporterConfig = mkOption {
      type = exporterConfigType;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable {
    };
}
