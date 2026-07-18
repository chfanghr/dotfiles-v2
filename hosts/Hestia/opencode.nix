{
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.fanghr = {
    imports = [inputs.agent-skills.homeManagerModules.default];

    programs = {
      opencode = {
        enable = true;
        enableMcpIntegration = true;
        extraPackages = [
          (pkgs.python3.withPackages (pyPkgs: [
            pyPkgs.pypdf
          ]))
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

      agent-skills = {
        enable = true;
        targets.opencode.enable = true;
        sources = {
          anthropic-skills = {
            path = inputs.anthropic-skills;
            subdir = "skills";
          };
          nhooey-nix-skills = {
            path = inputs.nhooey-nix-skills;
            subdir = "skills";
          };
          ojii3-dotfiles = {
            path = inputs.ojii3-dotfiles;
            subdir = "modules/home/ai/skills";
          };
        };
        skills.enable = [
          # anthropic-skills
          "pdf"
          # nhooey-nix-skills
          "nix-flakes"
          "nix-flake-recursive-bump-input-versions"
          # ojii3-dotfiles
          "using-flake-parts"
          "missing-tools"
          "nix-module-options"
        ];
      };
    };
  };
}
