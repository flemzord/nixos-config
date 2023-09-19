{ config, pkgs, lib, ... }:

{
  services = {
    uptime-kuma = {
      enable = true;
    };
  };
}
