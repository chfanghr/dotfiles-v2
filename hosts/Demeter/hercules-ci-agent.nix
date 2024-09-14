{config, ...}: {
  services.hercules-ci-agent = {
    enable = true;
    settings = {
      clusterJoinTokenPath = config.age.secrets.hci-token.path;
      binaryCachesPath = config.age.secrets.hci-binary-caches.path;
    };
  };

  age.secrets = {
    hci-token = {
      owner = "hercules-ci-agent";
      file = ../../secrets/demeter-hci-token.age;
    };
    hci-binary-caches = {
      owner = "hercules-ci-agent";
      file = ../../secrets/demeter-hci-binary-caches.age;
    };
  };
}
