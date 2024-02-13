{pkgs, ...}: {
  users.users.thungghuan = {
    openssh.authorizedKeys.keyFiles = [ ./authorizedKeys ]; 
    initialHashedPassword = # thungghuan
      "$y$j9T$JrXM1qo9HZF17tTK.uydJ1$lG3.3fWwF4Q.ZjsomjQWZOCG0cF2dqCwVuvfkBEgaP";
    isNormalUser = true;
    createHome = true;
    shell = pkgs.zsh;
  };
}
