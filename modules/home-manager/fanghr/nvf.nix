{
  vim = {
    viAlias = false;
    vimAlias = true;

    clipboard.enable = true;

    keymaps = [
      {
        key = "<leader>j";
        mode = "n";
        silent = true;
        action = ":Neotree toggle<CR>";
      }
    ];

    options = {
      expandtab = true;

      tabstop = 2;
      shiftwidth = 2;
    };

    theme = {
      enable = true;
      style = "night";
      name = "tokyonight";
    };

    spellcheck = {
      enable = true;
      programmingWordlist.enable = true;
    };

    lsp = {
      enable = true;
      trouble.enable = true;
      lspsaga.enable = true;
      nvim-docs-view.enable = true;
      lightbulb.enable = true;
      lspkind.enable = true;
    };

    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      nix.enable = true;
      markdown.enable = true;
      lua.enable = true;
      rust = {
        enable = true;
        extensions.crates-nvim.enable = true;
        lsp = {
          package = ["rust-analyzer"];
          opts = ''
            ['rust-analyzer'] = {
              files = {
                excludeDirs = {
                    ".cargo",
                    ".direnv",
                    ".git",
                    "target",
                },
              },
            },
          '';
        };
      };
      toml.enable = true;
      ocaml.enable = true;
      haskell.enable = true;
      json.enable = true;
    };

    statusline = {
      lualine = {
        enable = true;
        theme = "tokyonight";
      };
    };

    autopairs.nvim-autopairs.enable = true;
    autocomplete.blink-cmp.enable = true;
    filetree.neo-tree.enable = true;
    tabline.nvimBufferline.enable = true;
    treesitter.context.enable = true;

    git = {
      enable = true;
      neogit.enable = true;
    };

    utility = {
      undotree.enable = true;
      multicursors.enable = true;
    };

    terminal.toggleterm = {
      enable = true;
      lazygit.enable = true;
    };

    comments.comment-nvim.enable = true;

    visuals = {
      nvim-scrollbar.enable = true;
      fidget-nvim.enable = true;
      cinnamon-nvim.enable = true;
      blink-indent.enable = true;
    };

    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };

    notify.nvim-notify.enable = true;

    ui = {
      noice.enable = true;
      borders.enable = true;
      illuminate.enable = true;
      fastaction.enable = true;
    };

    session.nvim-session-manager.enable = true;
  };
}
