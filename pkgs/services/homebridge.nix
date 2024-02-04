{
  virtualisation.oci-containers.containers = {
    homebridge = {
      image = "homebridge/homebridge:latest";
      extraOptions = [ "--network=host" ];
      volumes = [ "homebridge:/homebridge" ];
      autoStart = true;
    };
  };
}
