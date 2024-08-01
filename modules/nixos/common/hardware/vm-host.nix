{
  config,
  lib,
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

  cpuProps = config.dotfiles.nixos.props.hardware.cpu;
  inherit (config.dotfiles.nixos.props.users) superUser;
in {
  options.dotfiles.nixos.props.hardware.vmHost = mkPropOption "runs vms";

  config = mkIf config.dotfiles.nixos.props.hardware.vmHost (mkMerge [
    {
      programs.dconf.enable = true;

      users.users.${superUser}.extraGroups = [
        "libvirtd"
      ];

      home-manager.users.${superUser}.home.packages = with pkgs; [
        virt-manager
        virt-viewer
        spice
        spice-gtk
        spice-protocol
        win-virtio
        win-spice
      ];

      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            swtpm.enable = true;
            ovmf.enable = true;
            ovmf.packages = [pkgs.OVMFFull.fd];
          };
        };
        spiceUSBRedirection.enable = true;
      };
      services.spice-vdagentd.enable = true;
    }
    (
      mkIf cpuProps.amd {
        boot = {
          kernelModules = ["kvm-amd"];
          extraModprobeConfig = ''
            options kvm_amd nested=1
          '';
        };
      }
    )
    (
      mkIf cpuProps.intel {
        boot = {
          kernelModules = ["kvm-intel"];
          extraModprobeConfig = ''
            options kvm_intel nested=1
          '';
        };
      }
    )
  ]);
}
