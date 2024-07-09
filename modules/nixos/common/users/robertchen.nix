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
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDi4qQcCF5W+5LspdHlXFfas+xuYmP6AqcoHaJFIpiISDPXazzmvf6iqVVnj0qmxeIf+NPu7GJuROh5jBet2g8Sc9ah8FDSpY4jgmxVlaSDcYL54+zv7+B+p2Sty+JkUcdErsXjCNk9BpY6bzXpP+jH6NRsiBK0qN7XUHkeCD5piqGnLB+0gKvpyRLe75azyKg5DsaHb00Wy0FN+oWx5dlFWZQQUCLQZgqQ6K295ZQFZwccVPLmGBoBJWLtXtq3PAFF1xh6rPwltqpqVo4I02D1/iCQ+dCugmDeyNXRAgXTPsTCsDp0EniDtbE4ufv67YghoJHkcrjdLujRWIfY2qyLVME2FRVn9m4UklXfFbQ1c/svna6Vd+BfkoOHOQffbZXF4+xswpMtKu6yuWnXqRzTda7gFP1LvB77QVfSzfrZi9nQqaT98SGgrE0eNTU291+xmLwlt19uWh5WiQMwqQbxE6CufRNN5wn1YOshW4Si4hFvNgEWLtCU5M4l3MKHVz9nOUpeSqxoS7RDgM1M/E2fGCJJij0q89w677VoBtqilTDM+SiF3pz1Z2aOmmjIzRlTEZ1/Kwtnt6kkWX0zUtALNUF0jqCuvAE6AzkFYizi/ObOJutvbJya8C4RvI0POYROZDgJGul3fwi1kIEf13fItsP38alcEoeghOj2cmP8xw== chenhaohua@MacBook-Air"
      ];
      hashedPassword = "$6$793W8FLb87n654fF$mM4R0qoB1LNgmemdvmNI/MRGSzzrFBVMZNeyaeV6FtXak9MeXn8dyAE4sfSChp8asB/6ZE6WqQAhaeOl6Cmc2.";
    };
  };
}
