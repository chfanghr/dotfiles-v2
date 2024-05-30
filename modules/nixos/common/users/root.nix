{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types mkIf mkForce;

  inherit (config.dotfiles.nixos.props.users) rootAccess;
  inherit (config.users.users) root;
in {
  options.dotfiles.nixos.props.users.rootAccess = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf rootAccess {
    assertions = [
      {
        assertion = rootAccess -> (root.hashedPassword != null && root.openssh.authorizedKeys.keys != []);
        message = "You enabled root access, but either password or openssh credential was not set";
      }
    ];

    services.openssh.settings.PermitRootLogin = mkForce "prohibit-password";
  };
}
