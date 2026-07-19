{
  lib,
  config,
  ...
}: let
  cfg = config.dotfiles.shared;
in {
  options.dotfiles.shared = let
    inherit (lib) mkOption types mdDoc;

    mkPropSwitch = name:
      mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Shared property: this machine ${name}";
      };

    proxyType = types.submodule {
      options = {
        address = mkOption {
          type = types.str;
        };
        http.port = mkOption {
          type = types.port;
        };
        socks5.port = mkOption {
          type = types.port;
        };
      };
    };

    locationType = types.submodule (
      {name, ...}: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
          };

          timeZone = mkOption {
            type = types.nullOr types.str;
            default = null;
          };

          networking.lan.ipv4 = {
            prefixLength = mkOption {
              type = types.nullOr types.ints.u8;
              default = null;
            };

            router.address = mkOption {
              type = types.nullOr types.str;
              default = null;
            };

            gfwBypass = {
              gateway.address = mkOption {
                type = types.nullOr types.str;
                default = null;
              };
              proxy = mkOption {
                type = types.nullOr proxyType;
                default = null;
              };
            };
          };

          prometheus = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };
      }
    );
  in {
    locations = mkOption {
      type = types.attrsOf locationType;
    };

    props = {
      locationName = mkOption {
        type = types.str;
        default = "mars";
      };

      location = mkOption {
        type = locationType;
        default = cfg.locations.${cfg.props.locationName};
        readOnly = true;
      };

      networking.lan.ipv4.gfwBypass = {
        useProxy = mkPropSwitch "uses proxy";
        useGateway = mkPropSwitch "uses gateway";
      };
    };
  };

  config = {
    assertions = let
      inherit (lib) hasAttrByPath;
    in [
      {
        assertion = hasAttrByPath [cfg.props.locationName] (cfg.locations);
        message = "location ${cfg.props.locationName} not defined";
      }
      {
        assertion = let
          l = cfg.props.location.networking.lan.ipv4.gfwBypass;

          c = cfg.props.networking.lan.ipv4.gfwBypass;
        in
          (c.useProxy -> (l.proxy != null)) && (c.useGateway -> (l.gateway.address != null));
        message = "GFW bypass not available at location ${cfg.props.locationName}";
      }
    ];

    dotfiles.shared.locations = {
      "mars" = {};
    };
  };
}
