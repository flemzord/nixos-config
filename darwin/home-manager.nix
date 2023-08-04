{ config, pkgs, lib, ... }:

let
  common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; lib = lib; };
  common-files = import ../common/files.nix {};
  user = "flemzord"; in
{
  imports = [
    <home-manager/nix-darwin>
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
  local.dock.entries = [
    { path = "/Applications/Slack.app/"; }
    { path = "/Applications/Discord.app/"; }
    { path = "/Applications/Beeper.app/"; }
    { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
    { path = "/Applications/Drafts.app/"; }
    { path = "/System/Applications/Home.app/"; }
    {
      path = "${config.users.users.${user}.home}/.local/share/bin/emacs-launcher.command";
      section = "others";
    }
    {
      path = "${config.users.users.${user}.home}/.local/share/";
      section = "others";
      options = "--sort name --view grid --display folder";
    }
    {
      path = "${config.users.users.${user}.home}/.local/share/downloads";
      section = "others";
      options = "--sort name --view grid --display stack";
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

  # These app IDs are from using the mas CLI app
  # mas = mac app store
  # https://github.com/mas-cli/mas
  #
  # $ mas search <app name>
  #
  homebrew.casks = pkgs.callPackage ./casks.nix {};
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
      home.packages = pkgs.callPackage ./packages.nix {};
      home.file = common-files // import ./files.nix { config = config; pkgs = pkgs; };
      programs = common-programs // {};

      # https://github.com/nix-community/home-manager/issues/3344
      # Marked broken Oct 20, 2022 check later to remove this
      # Confirmed still broken, Mar 5, 2023
      manual.manpages.enable = false;
    };
  };
}
