{ config, pkgs, lib, ... }:

{
  services = {
    cloudflared = {
      enable = true;
      tunnels = {
        "01eea35c-34c5-42c0-811c-ad23cf8bc655" = {
          credentialsFile = "/etc/nixos/secrets/01eea35c-34c5-42c0-811c-ad23cf8bc655.json";
          default = "http_status:404";
          ingress = {
            "n8n.flemzord.ovh" = {
              service = "http://localhost:5678";
            };
          };
        };
      };
    };
  };
}