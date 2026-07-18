{
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.fanghr = {
    programs = {
      opencode = {
        enable = true;
        enableMcpIntegration = true;
        extraPackages = [
          pkgs.python3
        ];
        settings = {
          autoupdate = false;
          permission = {
            external_directory = {
              "/nix/store/**" = "allow";
            };
            edit = {
              "/nix/store/**" = "deny";
            };
          };
        };
      };

      mcp = {
        enable = true;
        servers = {
          nixos.command = "${inputs.mcp-nixos.packages.${pkgs.stdenv.system}.default}/bin/mcp-nixos";
        };
      };
    };
  };
}
