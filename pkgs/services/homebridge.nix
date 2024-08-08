{
  virtualisation.oci-containers.containers = {
    homebridge = {
      image = "homebridge/homebridge:2024-06-27";
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
