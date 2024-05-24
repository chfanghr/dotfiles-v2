{pkgs, ...}: {
  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    enableScDaemon = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ./gpg/main.gpg;
        trust = 5;
      }
    ];
  };
}
