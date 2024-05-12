{pkgs, ...}: {
  users.users.thungghuan = let
    authorizedKeysGH = pkgs.fetchurl {
      url = "https://github.com/thungghuan.keys";
      hash = "sha256-WOID7twDwI9KaeCRbwBBGmYOLp9UCwSImzkoEkbc6i0=";
    };
  in {
    openssh.authorizedKeys.keyFiles = [authorizedKeysGH];
    initialHashedPassword =
      # thungghuan
      "$y$j9T$JrXM1qo9HZF17tTK.uydJ1$lG3.3fWwF4Q.ZjsomjQWZOCG0cF2dqCwVuvfkBEgaP";
    isNormalUser = true;
    createHome = true;
    shell = pkgs.zsh;
  };
}
