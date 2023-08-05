{ config, pkgs, lib, ... }:

{
    virtualisation = {
        docker = {
            enable = true;
            storageDriver = "btrfs";
            autoPrune = {
              dates = "daily";
              flags = ["--all" "--volumes"];
            };
        };
    };
}