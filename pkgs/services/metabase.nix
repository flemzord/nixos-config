{ config, pkgs, lib, ... }:

{
  services = {
    metabase = {
      enable = true;
      openFirewall = true;
    };
  };
}