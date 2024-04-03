{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mdDoc mkDefault mkIf getExe';
  inherit (pkgs) writeShellScript;

  cfg = config.services.generate-nix-cache-key;

  nix = writeShellScript "nix-with-nix-command-enabled" ''
    ${getExe' pkgs.nix "nix"} --extra-experimental-features nix-command $@
  '';
in {
  options = {
    services.generate-nix-cache-key = {
      enable = mkEnableOption (mdDoc "automatically generating nix binary cache key, if it's not already present");

      privateKeyPath = mkOption {
        type = types.path;
        default = "/etc/nix/private-key";
        description = mdDoc "Path to the private key.";
      };

      publicKeyPath = mkOption {
        type = types.path;
        default = "/etc/nix/public-key";
        description = mdDoc "Path to the public key";
      };

      keyName = mkOption {
        type = types.str;
        description = mdDoc "Identifier of the key. By default, `\${networking.hostName}-1` will be used.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.generate-nix-cache-key.keyName = mkDefault "${config.networking.hostName}-1";

    systemd.services.generate-nix-cache-key = {
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "oneshot";
      serviceConfig = {
        User = "root";
        Group = "root";
      };
      script = ''
        if [ ! -f ${cfg.privateKeyPath} ]; then
          echo "private key not found, generating"
          install -m 400 <(${nix} key generate-secret --key-name "${cfg.keyName}") "${cfg.privateKeyPath}"
        fi
        echo "converting private key to public key"
        install -m 444 <(cat "${cfg.privateKeyPath}" | ${nix} key convert-secret-to-public) "${cfg.publicKeyPath}"
      '';
    };

    nix.extraOptions = ''
      secret-key-files = ${cfg.privateKeyPath}
    '';
  };
}
