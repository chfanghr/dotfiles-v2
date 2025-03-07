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
        hash = "sha256-v10FpLQzFRrgSkQ1Xcd/HRdgcP0L0NC0kV/1pGq5nBg=";
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
