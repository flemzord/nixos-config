{ config, pkgs, lib, ... }:

{
  services = {
    n8n = {
      enable = true;
      openFirewall = true;
    };
  };
}
