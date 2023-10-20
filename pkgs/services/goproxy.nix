{
  virtualisation.oci-containers.containers = {
    goproxy = {
      image = "goproxy/goproxy:latest";
      volumes = [ "goproxy:/go" ];
      autoStart = true;
    };
  };
}
