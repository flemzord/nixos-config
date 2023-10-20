{
  virtualisation = {
    backend = "docker";
    containers.goproxy = {
      volumes = [
        "goproxy:/go"
      ];
      environment.TZ = "Europe/Paris";
      image = "goproxy/goproxy:latest";
    };
  };
}
