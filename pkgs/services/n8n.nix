{
  virtualisation.oci-containers.containers = {
    n8n = {
      image = "docker.n8n.io/n8nio/n8n:1.69.2";
      ports = [ "5678:5678" ];
      volumes = [ "n8n_data:/home/node/.n8n" ];
      environment = {
        N8N_SECURE_COOKIE = "true";
        GENERIC_TIMEZONE = "Europe/Paris";
        TZ = "Europe/Paris";
        N8N_HOST = "n8n.flemzord.ovh";
        N8N_PORT = "5678";
        N8N_PROTOCOL = "https";
        WEBHOOK_URL = "https://n8n.flemzord.ovh/";
      };
      autoStart = true;
    };
  };
}
