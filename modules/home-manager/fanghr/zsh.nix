{
  programs = {
    zsh = {
      enable = true;
      enableVteIntegration = true;

      history = {
        size = 1000000;
        path = "$HOME/.local/share/zsh/history";
      };

      initExtra = ''
        if [[ -r "$HOME/.iterm2_shell_integration.zsh" ]]; then
          source "$HOME/.iterm2_shell_integration.zsh"
        fi

        export GPG_TTY="$(tty)"
      '';

      prezto = {
        enable = true;
        prompt = {
          theme = "smiley";
          showReturnVal = true;
          pwdLength = "short";
        };
        terminal.autoTitle = true;
        syntaxHighlighting.highlighters = [
          "main"
          "brackets"
          "pattern"
          "line"
          "root"
        ];
        pmodules = [
          "git"
          "environment"
          "terminal"
          "editor"
          "history"
          "directory"
          "spectrum"
          "utility"
          "completion"
          "prompt"
          "syntax-highlighting"
          "history-substring-search"
          "autosuggestions"
          "rsync"
          "ssh"
          "osx"
        ];
      };

      shellAliases = {
        ssh-dont-check-host-key = ''ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'';
      };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
    };

    zellij.enable = true;
  };
}
