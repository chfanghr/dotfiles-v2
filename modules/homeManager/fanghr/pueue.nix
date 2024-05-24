{
  pkgs,
  lib,
  ...
}: let
  pueueConfigObject = {
    client = {
      restart_in_place = false;
      read_local_msg = true;
      show_confirmation_questions = false;
      show_expanded_aliases = false;
      dark_mode = false;
    };
    daemon = {
      pause_group_on_failure = false;
      pause_all_on_failure = false;
    };
    shared = {
      use_unix_socket = true;
      host = "127.0.0.1";
      port = 6924;
    };
  };

  inherit (pkgs) formats writeShellScriptBin;
  inherit (lib) getExe';

  yaml = formats.yaml {};

  pueueConfigFile = yaml.generate "pueue.yml" pueueConfigObject;

  pueueClientWithOurConfig = writeShellScriptBin "pueue" ''
    PUEUE_CONFIG_PATH=${pueueConfigFile} ${getExe' pkgs.pueue "pueue"} $@
  '';
in {
  systemd.user.services.pueued = {
    Unit = {
      Description = "Pueue Daemon - CLI process scheduler and manager";
    };

    Service = {
      Restart = "on-failure";
      ExecStart = "${getExe' pkgs.pueue "pueued"} -v -c ${pueueConfigFile}";
    };

    Install.WantedBy = ["default.target"];
  };

  home.packages = [
    pueueClientWithOurConfig
  ];
}
