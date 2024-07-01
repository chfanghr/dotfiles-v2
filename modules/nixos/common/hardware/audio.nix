{
  lib,
  config,
  pkgs,
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
      mkIf config.dotfiles.nixos.props.hardware.bluetooth.enable {
        services.pipewire.wireplumber.configPackages = [
          (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
            monitor.bluez.properties = {
              bluez5.roles = [ a2dp_sink a2dp_source bap_sink bap_source hsp_hs hsp_ag hfp_hf hfp_ag ]
              bluez5.codecs = [ sbc sbc_xq aac ]
              bluez5.enable-sbc-xq = true
              bluez5.hfphsp-backend = "native"
            }
          '')
        ];
      }
    )
  ]);
}
