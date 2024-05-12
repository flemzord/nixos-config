{
  virtualisation.oci-containers.containers = {
    n8n = {
      image = "docker.n8n.io/n8nio/n8n:1.40.0";
      ports = [ "5678:5678" ];
      volumes = [ "n8n_data:/home/node/.n8n" ];
      environment = {
        GENERIC_TIMEZONE = "Europe/Paris";
        TZ = "Europe/Paris";
      };
      autoStart = true;
    };
  };
}
