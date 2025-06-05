{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (config.athena) persistPath;
in {
  options.athena.persistPath = mkOption {
    type = types.path;
    default = "/persist";
    readOnly = true;
  };

  config = {
    environment.persistence.${persistPath} = {
      enable = true;

      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        {
          directory = "/var/lib/tailscale/";
          mode = "u=rwx,g=,o=";
        }
        {
          directory = "/var/lib/nixos-containers/";
          mode = "u=rwx,g=,o=";
        }
        {
          directory = "/var/lib/sing-box/";
          mode = "u=rwx,g=,o=";
        }
        {
          directory = "/var/db/sudo/lectured";
          mode = "u=rwx,g=,o=";
        }
      ];

      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };

    age.identityPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
  };
}
