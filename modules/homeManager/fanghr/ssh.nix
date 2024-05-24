{
  programs.ssh = {
    enable = true;
    matchBlocks = let
      proxyCommand = "nc -X 5 -x 10.42.0.1:1087 %h %p";
    in {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        inherit proxyCommand;
      };
      "gist.github.com" = {
        hostname = "github.com";
        user = "git";
        inherit proxyCommand;
      };
    };
  };
}
