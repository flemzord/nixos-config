{ config, pkgs, lib, ... }:

{
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        dates = "daily";
        flags = [ "--all" "--volumes" ];
      };
      daemon.settings = {
        dns = [ "1.1.1.1" "9.9.9.9" ];
      };
    };
    oci-containers.backend = "docker";
  };
}
