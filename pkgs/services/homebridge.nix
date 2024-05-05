{
  virtualisation.oci-containers.containers = {
    homebridge = {
      image = "homebridge/homebridge:2024-05-02";
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
