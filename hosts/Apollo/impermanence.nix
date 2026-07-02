{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  mp = config.apollo.mountpoints.persist;
in {
  options.apollo.mountpoints.persist = mkOption {
    type = types.path;
    default = "/persist";
  };

  config = {
    environment.persistence.${mp} = {
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
          directory = "/var/db/sudo/lectured";
          mode = "u=rwx,g=,o=";
        }
        {
          directory = "/var/lib/sbctl";
          mode = "u=rwx,g=,o=";
        }
        {
          directory = "/etc/secrets/initrd";
          mode = "u=rwx,g=,o=";
        }
        {
          directory = "/etc/secrets/zfs-keys";
          mode = "u=rwx,g=,o=";
        }
      ];

      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };

    age.identityPaths = ["/${mp}/etc/ssh/ssh_host_ed25519_key"];

    fileSystems.${mp}.neededForBoot = true;
  };
}
