_:

{
  # Home Assistant in Docker
  virtualisation.oci-containers = {
    containers.homeassistant = {
      volumes = [
        "home-assistant:/config"
        "/var/run/dbus:/run/dbus:ro"
      ];
      environment.TZ = "Europe/Paris";
      image = "ghcr.io/home-assistant/home-assistant:2026.2.2";
      extraOptions = [
        "--network=host"
      ];
    };
  };
  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ 8123 ];
  # };
}
