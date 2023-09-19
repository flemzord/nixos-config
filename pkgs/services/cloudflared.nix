{ config, pkgs, lib, ... }:

{
  services = {
    cloudflared = {
      enable = true;
    };
  };
}
