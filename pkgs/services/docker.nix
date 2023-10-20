{ config, pkgs, lib, ... }:

{
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        dates = "daily";
        flags = [ "--all" "--volumes" ];
      };
    };
    oci-containers.backend = "docker";
  };
}
