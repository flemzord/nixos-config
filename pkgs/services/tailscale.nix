{ config, pkgs, lib, ... }:

{
  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server"
    };
  };
}
