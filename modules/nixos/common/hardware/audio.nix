{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mdDoc mkIf mkMerge;
  mkPropOption = name:
    mkOption {
      type = types.bool;
      default = false;
      description = mdDoc "NixOS Property: this machine ${name}";
    };
in {
  options.dotfiles.nixos.props.hardware.audio = mkPropOption "is capable of outputing audio";

  config = mkIf config.dotfiles.nixos.props.hardware.audio (mkMerge [
    {
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    }
    (
      mkIf config.services.avahi.enable {
        services.pipewire = {
          raopOpenFirewall = true;

          extraConfig.pipewire."10-airplay"."context.modules" = [
            {name = "libpipewire-module-raop-discover";}
          ];
        };
      }
    )
  ]);
}
