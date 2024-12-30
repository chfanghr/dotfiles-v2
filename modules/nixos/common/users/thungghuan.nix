{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mkIf;
in {
  options.dotfiles.nixos.props.users.guests.thungghuan = mkOption {
    type = types.bool;
    default = false;
  };
  config = mkIf config.dotfiles.nixos.props.users.guests.thungghuan {
    users.users.thungghuan = let
      authorizedKeysGH = pkgs.fetchurl {
        url = "https://github.com/thungghuan.keys";
        hash = "sha256-41RDwHvlkQPYEIcDDuBE46JIy1lyRQCB92Od6Fu0JvU=";
      };
    in {
      openssh.authorizedKeys.keyFiles = [authorizedKeysGH];
      initialHashedPassword =
        # thungghuan
        "$y$j9T$JrXM1qo9HZF17tTK.uydJ1$lG3.3fWwF4Q.ZjsomjQWZOCG0cF2dqCwVuvfkBEgaP";
      isNormalUser = true;
      createHome = true;
    };
  };
}
