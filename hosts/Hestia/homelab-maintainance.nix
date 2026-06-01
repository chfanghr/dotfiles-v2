{
  home-manager.users.fanghr.programs.zellij.layouts.homelab = {
    layout = {
      cwd = "/home/fanghr/Developer/dotfiles-v2";

      _children = [
        {
          default_tab_template = {
            _children = [
              {
                pane = {
                  _props = {
                    borderless = true;
                    size = 1;
                  };
                  plugin.location = "zellij:tab-bar";
                };
              }
              {
                children = {};
              }
              {
                pane = {
                  _props = {
                    borderless = true;
                    size = 1;
                  };
                  plugin.location = "zellij:status-bar";
                };
              }
            ];
          };
        }
        {
          tab = {
            _props = {
              focus = true;
              name = "deployment + lazygit";
            };
            _children = [
              {
                pane = {
                  _props.split_direction = "vertical";
                  _children = [
                    {pane._props.size = "50%";}
                    {
                      pane._props = {
                        size = "50%";
                        command = "lazygit";
                      };
                    }
                  ];
                };
              }
            ];
          };
        }
        {
          tab = {
            _props.name = "machine status";
            _children = [
              {
                pane._props.command = "btop";
              }
            ];
          };
        }
        {
          tab = {
            _props.name = "opencode";
            _children = [
              {pane._props.command = "opencode";}
            ];
          };
        }
      ];
    };
  };
}
