{
  virtualisation.oci-containers.containers = {
    goproxy = {
      image = "goproxy/goproxy:latest";
      volumes = [ "goproxy:/go" ];
      ports = [ "8081:8081" ];
      autoStart = true;
    };
  };
}
