{pkgs, ...}: {
  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = ["history" "git" "sudo"];
        theme = "kardan";
      };
      shellAliases = {
        ssh-dont-check-host-key = ''ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'';
      };
      plugins = [
        {
          name = "zsh-wakatime";
          src = pkgs.fetchFromGitHub {
            owner = "wbingli";
            repo = "zsh-wakatime";
            rev = "7396e143f2eb048a4a6d64dacae81c52e1ad72ab";
            sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
      ];
    };

    lsd = {
      enable = true;
      enableAliases = true;
    };

    zellij.enable = true;
  };
}
