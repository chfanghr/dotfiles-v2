{lib, ...}: {
  perSystem = {
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    devShells.default = self'.devShells.pre-commit.overrideAttrs (
      _: prev: {
        buildInputs =
          (
            if prev ? buildInputs
            then prev.buildInputs
            else []
          )
          ++ (
            lib.filter
            (
              p: let
                ok = lib.elem system pkgs.hello.meta.platforms;
              in
                lib.warnIfNot ok "${p.name} is not supported on ${system}" ok
            )
            [
              inputs'.agenix.packages.default
              inputs'.disko.packages.default
              inputs'.nixos-anywhere.packages.default
              inputs'.deploy-rs.packages.default
              inputs'.qbittorrent-password.packages.default
              pkgs.nurl
              pkgs.nixos-facter
              pkgs.openssl
              (
                pkgs.writeScriptBin "mk-oidc-client-id" ''
                  ${lib.getExe pkgs.authelia} crypto rand --length 72 --charset rfc3986
                ''
              )
              (pkgs.writeScriptBin "mk-oidc-client-secret" ''
                ${lib.getExe pkgs.authelia} crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
              '')
              (pkgs.writeScriptBin "mk-rsa-keypair" ''
                ${lib.getExe pkgs.authelia} crypto pair rsa generate
              '')
            ]
          );
      }
    );
  };
}
