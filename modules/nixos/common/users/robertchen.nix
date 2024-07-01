{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types mkIf;
in {
  options.dotfiles.nixos.props.users.guests.robertchen = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf config.dotfiles.nixos.props.users.guests.robertchen {
    users.users.robertchen = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrl5FDgzMAVYpDNOhfHCh4Lf7RJFFsnrZfCAgjv8lY+CnlzbzbMOqJdU6apW0Q5H1R8IOuYhlHkH/cjbXxamFPHBzBBPCYKNqCa1I7aw4WL8drS9DUhhYd54CoO5FN+7Nzg1LASJo/BZzwxg5XAzA35/sj6kvShKjNKI3ucLLD9UztPtQ+vCQn36NBFrGfvyjvBGDWcDMyzeARkpw/OOpspfZ4L6LLwYkebdj+RTvMGL9QDjn97O3FnxyfOe4OwadBebhKjsGAEsbOgfNA9f7l/YRGthtF64fNXvbszuDKG6AbOHJzAEEowJtz+Ievn2AZ6Tji1cF4kp5Ys7+l34kKAVGoEG1cXULSNd+LEQbU9nCuxH8mTeI5xuKt4xxT/xwi+WgJagOt62GTSf4EsTMJHsrgI1ItYWcsIBiaZLiWtv16Zpcmw5JW7Dpk3x5f4C+xo+dUKAVCmgVS2rR5wO91epAslFOg1lXXa4V1kJ/UAvpwqccTIMqoSX/uc/4blQM= robertchen@DESKTOP-9VSVNCN"
      ];
      hashedPassword = "$6$793W8FLb87n654fF$mM4R0qoB1LNgmemdvmNI/MRGSzzrFBVMZNeyaeV6FtXak9MeXn8dyAE4sfSChp8asB/6ZE6WqQAhaeOl6Cmc2.";
    };
  };
}
