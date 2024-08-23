{
  config,
  lib,
  ...
}: let
  inherit (lib) range nameValuePair optionalString;
  inherit (builtins) listToAttrs map toString;
in {
  services.github-runners = listToAttrs (map (i: let
    name = "chfanghr-dotfiles-v2${optionalString (i != 0) "-${toString i}"}";
  in
    nameValuePair name
    {
      tokenFile = config.age.secrets."github-runner-token-chfanghr-dotfiles-v2".path;
      url = "https://github.com/chfanghr/dotfiles-v2";
    }) (range 0 10));

  age.secrets."github-runner-token-chfanghr-dotfiles-v2".file = ../../secrets/github-runner-token-chfanghr-dotfiles-v2.age;
}
