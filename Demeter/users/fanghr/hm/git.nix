{
  programs.git = {
    enable = true;

    difftastic.enable = false;

    ignores = [
      "*~"
      ".DS_Store"
      ".envrc"
      ".direnv"
      ".vscode"
      ".idea"
      "dist-newstyle/"
      "clear\\ /"
    ];

    signing = {
      key = "0x06DA3273BC714AE7";
      signByDefault = true;
    };

    userEmail = "chfanghr@gmail.com";
    userName = "Hongrui Fang";

    aliases = rec {
      lg1 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      lg2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
      lg = lg1;
      hh = "rev-parse HEAD";
    };

    extraConfig = {
      core.autocrlf = "input";
      init.defaultBranch = "main";
    };

    lfs = {
      enable = true;
    };
  };
}
