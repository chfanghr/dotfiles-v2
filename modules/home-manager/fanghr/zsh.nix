{
  programs = {
    zsh = {
      enable = true;
      enableVteIntegration = true;

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
