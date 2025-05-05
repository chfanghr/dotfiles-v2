let
  cardanoUser = "cardano-containerized";
  cardanoGroup = "cardano-containerized";
  cardanoUid = 987;
  cardanoGid = 984;

  postgresqlUser = "postgresql-containerized";
  postgresqlGroup = "postgresql-containerized";
  postgresqlUid = 986;
  postgresqlGid = 983;

  dataDir = "/data/cardano";
  preprodData = "${dataDir}/preprod";
  mainnetData = "${dataDir}/mainnet";

  mkTmpFileRules = baseDataDir: {
    ${baseDataDir}.d = {
      user = "root";
      group = "root";
      mode = "0755";
    };
    "${baseDataDir}/node-db".d = {
      user = cardanoUser;
      group = cardanoGroup;
      mode = "0755";
    };
    "${baseDataDir}/postgresql".d = {
      user = postgresqlUser;
      group = postgresqlGroup;
      mode = "0755";
    };
  };
in {
  users = {
    users = {
      ${cardanoUser} = {
        uid = cardanoUid;
        group = cardanoGroup;
        isSystemUser = true;
      };
      ${postgresqlUser} = {
        uid = postgresqlUid;
        group = postgresqlGroup;
        isSystemUser = true;
      };
    };

    groups = {
      ${cardanoGroup}.gid = cardanoGid;
      ${postgresqlGroup}.gid = postgresqlGid;
    };
  };

  fileSystems = {
    ${preprodData} = {
      device = "tank/cardano/preprod";
      fsType = "zfs";
      options = ["noatime" "noexec"];
    };
    ${mainnetData} = {
      device = "tank/cardano/mainnet";
      fsType = "zfs";
      options = ["noatime" "noexec"];
    };
  };

  systemd.tmpfiles.settings."10-cardano-data" =
    {
      ${dataDir}.d = {
        user = "root";
        group = "root";
        mode = "0755";
      };
    }
    // mkTmpFileRules preprodData
    // mkTmpFileRules mainnetData;
}
