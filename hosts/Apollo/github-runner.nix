{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.apollo.mountpoints.github-runner = mkOption {
    type = types.path;
    default = "/data/github-runner";
    readOnly = true;
  };

  config = {
    # systemd.tmpfiles.settings."40-github-runner" = {
    #   ${config.apollo.mountpoints.github-runner}.d = {
    #   };
    # };
  };
}
