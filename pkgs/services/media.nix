{ config, pkgs, lib, ... }:

{
  services = {
    radarr = {                  #7878
      enable = true;
      user = "root";
      group = "users";
      openFirewall = true;
    };
    sonarr = {                  #8989
      enable = true;
      user = "root";
      group = "users";
      openFirewall = true;
    };
    bazarr = {                  #6767
      enable = true;
      user = "root";
      group = "users";
      openFirewall = true;
    };
    prowlarr = {                #9696
      enable = true;
      openFirewall = true;
    };
    transmission = {                  #9091
      enable = true;
      user = "root";
      group = "users";
      openFirewall = true;
      openRPCPort = true;
      performanceNetParameters = true;
      settings = {
        alt-speed-up = 10;
        alt-speed-down = 150;
        blocklist-enabled = true;
        blocklist-url = "https://github.com/sahsu/transmission-blocklist/releases/latest/download/blocklist.gz";
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = false;
      };
    };
    plex = {
        enable = true;
        dataDir = "/var/lib/plex";
        openFirewall = true;
        user = "plex";
        group = "plex";
    };
  };
}