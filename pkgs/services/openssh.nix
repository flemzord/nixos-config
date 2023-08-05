{ config, pkgs, lib, ... }:

{
  services = {
    openssh = {
      enable = true;
      openFirewall = true;
    };
  };
}
