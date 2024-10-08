{
  config,
  inputs,
  pkgs,
  ...
}: {
  services.hercules-ci-agent = {
    enable = true;
    package = inputs.hci-agent.packages.${pkgs.stdenv.system}.hercules-ci-agent;
    settings = {
      clusterJoinTokenPath = config.age.secrets.hci-token.path;
      binaryCachesPath = config.age.secrets.hci-binary-caches.path;
      secretsJsonPath = config.age.secrets.hci-secrets-json.path;
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
    hci-secrets-json = {
      owner = "hercules-ci-agent";
      file = ../../secrets/demeter-hci-secrets-json.age;
    };
  };
}
