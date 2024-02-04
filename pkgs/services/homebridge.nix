{
  virtualisation.oci-containers.containers = {
    homebridge = {
      image = "homebridge/homebridge:latest";
      networkMode = "host";
      volumes = [ "homebridge:/homebridge" ];
      autoStart = true;
    };
  };
}
