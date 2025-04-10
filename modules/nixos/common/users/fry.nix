{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types mkIf;
in {
  options.dotfiles.nixos.props.users.guests.fry = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf config.dotfiles.nixos.props.users.guests.fry {
    users.users.fry = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIEMm5O1Fc7pSfuPD5uuZ1I4PmZsP8WzJHiOv7Zqq7RT046ERv7YEC+TMD9X7nAXZX3bM+faPzQPv+XQW3T4L7c= fry@DESKTOP-D7VJM6V"
      ];
      createHome = true;
      hashedPassword = "$y$j9T$5wDnJ3y8ljamKvg.RxxlN0$dc.j9SXNObdszbooMvqybwNZZDfKbk0gYXF7TrbLDu0";
    };
  };
}
