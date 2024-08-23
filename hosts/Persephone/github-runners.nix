{config, ...}: {
  services.github-runners.chfanghr-dotfiles-v2 = {
    tokenFile = config.age.secrets."github-runner-token-chfanghr-dotfiles-v2".path;
    url = "https://github.com/chfanghr/dotfiles-v2";
  };

  age.secrets."github-runner-token-chfanghr-dotfiles-v2".file = ../../secrets/github-runner-token-chfanghr-dotfiles-v2.age;
}
