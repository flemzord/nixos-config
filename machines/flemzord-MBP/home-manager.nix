{ config, pkgs, lib, home-manager, ... }:

let
  shared-programs = import ../../pkgs/shared/home-manager.nix { inherit config; inherit pkgs; inherit lib; };
  user = "flemzord";
in
{
  imports = [
    ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  #  local.dock.position = "left";
  #  local.dock.autoHide = true;
  local.dock.entries = [
    { path = "/Applications/Arc.app/"; }
    { path = "/Applications/Slack.app/"; }
    { path = "/Applications/Discord.app/"; }
    { path = "/Applications/Beeper.app/"; }
    { path = "/Applications/Warp.app/"; }
    { path = "/System/Applications/Home.app/"; }
    {
      path = "/Applications";
      section = "others";
    }
    {
      path = "${config.users.users.${user}.home}/Downloads";
      section = "others";
      options = "--sort datemodified --view grid --display stack";
    }
  ];

  # We use Homebrew to install impure software only (Mac Apps)
  homebrew.enable = true;
  homebrew.onActivation = {
    autoUpdate = true;
    cleanup = "zap";
    upgrade = true;
  };
  homebrew.brewPrefix = "/opt/homebrew/bin";
  homebrew.casks = pkgs.callPackage ./casks.nix { };
  homebrew.brews = [
    "garden-io/garden/garden-cli"
  ];

  # These app IDs are from using the mas CLI app
  # mas = mac app store
  # https://github.com/mas-cli/mas
  #
  # $ mas search <app name>
  #
  homebrew.masApps = {
    "1Password for Safari" = 1569813296;
    "Bear" = 1091189122;
    "Infuse" = 1136220934;
    "Screegle" = 1591051659;
    "Tailscale" = 1475387142;
  };

  # Enable home-manager to manage the XDG standard
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = {
      home.stateVersion = "23.05";
      home.enableNixpkgsReleaseCheck = false;
      home.packages = pkgs.callPackage ./packages.nix { };
      programs = shared-programs // { };

      # https://github.com/nix-community/home-manager/issues/3344
      # Marked broken Oct 20, 2022 check later to remove this
      # Confirmed still broken, Mar 5, 2023
      manual.manpages.enable = false;
    };
  };
}
