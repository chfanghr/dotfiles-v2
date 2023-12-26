{
  virtualisation.oci-containers.containers.cs2 = {
    autoStart = true;
    ports = [
      "27015:27015"
      "27015:27015/udp"
      "27050:27050"
    ];
    image = "docker.io/joedwards32/cs2:latest";
    extraOptions = [ "--network=host" ];
    environment = {
      CS2_RCON_PORT = "27050";
      # CS2_LAN = "1";
      CS2_IP = "0.0.0.0";
      CS2_GAMEALIAS = "compatitive";
      CS2_BOT_DIFFICULTY = "3";
      CS2_BOT_QUOTA = "10";
      CS2_PW = "swatownang";
      CS2_RCONPW = "swatownang";
      CS2_SERVERNAME = "demeter";
      SRCDS_TOKEN="980995869076ECC909EA014BDEAC8EFD";
    };
    volumes = [
      "cs2-server:/home/steam/cs2-dedicated/"
    ];
  };
  networking.firewall = {
    allowedTCPPorts = [
      27015
      27050
    ];
    allowedUDPPorts = [
      27015
    ];
  };
}
