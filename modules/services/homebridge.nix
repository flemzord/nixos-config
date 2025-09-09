{
  virtualisation.oci-containers.containers = {
    homebridge = {
      image = "homebridge/homebridge:2025-05-16";
      extraOptions = [ "--network=host" ];
      volumes = [ "homebridge:/homebridge" ];
      autoStart = true;
    };
  };
  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ 8581 ];
  # };
}
