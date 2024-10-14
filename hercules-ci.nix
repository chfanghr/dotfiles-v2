{inputs, ...}: {
  imports = [
    inputs.hci-effects.flakeModule
  ];

  hercules-ci.flake-update = {
    enable = true;
    baseBranch = "main";
    createPullRequest = true;
    when = {
      minute = 45;
      hour = 12;
      dayOfWeek = "Sun";
    };
  };

  herculesCI.ciSystems = ["x86_64-linux"];
}
