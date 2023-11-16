{ config, pkgs, lib, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };
  };

  nix = {
    package = pkgs.nixUnstable;
    settings.trusted-users = [ "@admin" "flemzord" ];

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";
}
