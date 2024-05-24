{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types elem xor;
  cfg = config.dotfiles;
in {
  options.dotfiles = {
    props = mkOption {
      type = types.listOf (types.enum [
        "is-for-work"
        "is-nix-builder"
        "is-nix-consumer"
        "is-vps"
        "is-on-lan"
        "has-bluetooth"
        "needs-blueman"
        "has-audio"
        "has-rgb"
        "allows-root-login"
        "is-container-host"
        "runs-vscode-code-server"
        "use-router-proxy"
        "is-graphical"
        "has-amd-gpu"
        "has-nvidia-gpu"
        "has-intel-cpu"
        "has-amd-cpu"
        "is-for-gaming"
        "uses-yubikey"
        "has-wireless"
      ]);
      default = [];
    };

    hasProp = mkOption {
      type = types.functionTo types.bool;
      default = p: elem p cfg.props;
      readOnly = true;
    };

    hardware = {
      rgb = {
        motherboard = mkOption {
          type = types.str;
        };
        extraKernelModules = mkOption {
          type = types.listOf types.str;
          default = [];
        };
      };
      nvidia.driver = mkOption {
        type = types.package;
        default = config.boot.kernelPackages.nvidiaPackages.beta;
      };
    };

    nix.buildMachinePulicKeys = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    networking = {
      lanInterfaces = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      routerProxy = mkOption {
        type = types.string;
      };
    };
  };

  config = {
    assertions = let
      inherit (config.dotfiles) hasProp;
    in [
      {
        assertion = (hasProp "use-router-proxy") -> (hasProp "on-lan");
        message = "To use the proxy service provided by the lan router, the machine must be on lan network";
      }
      {
        assertion = (hasProp "on-lan") -> !(hasProp "vps");
        message = "A vps cannot be on lan network";
      }
      {
        assertion = (hasProp "vps") -> (hasProp "is-nix-consumer");
        message = "In general, vps are too weak to build its own system derivation on its own";
      }
      {
        assertion = (hasProp "vps") -> (hasProp "allow-root-login");
        message = "Root login must be enable on vps to allow `nixos-rebuild switch` without password";
      }
      {
        assertion = xor (hasProp "has-amd-cpu") (hasProp "has-intel-cpu");
        message = "A machine can either have a amd cpu or a intel cpu.";
      }
      {
        assertion = (hasProp "is-graphical") -> ((hasProp "has-amd-gpu") || (hasProp "has-nvidia-gpu"));
        message = "To start a graphical interface, a graphic card is required";
      }
      {
        assertion = (hasProp "is-for-gaming") -> (hasProp "is-graphical");
        message = "For gaming purposes, a machine must be graphical";
      }
    ];

    dotfiles = {
      nix.buildMachinePulicKeys = [
        "Demeter-1:st+mG+g+DIrAmwIz0DpkPD4XfLtzrElbMiKDR9Jf+Nw="
      ];
      networking.routerProxy = "http://10.42.0.1:1086";
    };
  };
}
