{ config, pkgs, lib, home-manager, ... }:

let
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
    "formancehq/tap/fctl"
    "loft-sh/tap/vcluster"
    "earthly/earthly/earthly"
    "renovate"
    "krew"
    "protobuf"
    "protoc-gen-go"
    "protoc-gen-go-grpc"
    "awscli"
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
    users.${user} = { pkgs, config, lib, ... }: {
      home.enableNixpkgsReleaseCheck = false;
      home.stateVersion = "21.11";

      home.packages = pkgs.callPackage ./packages.nix { };
      programs = { } // import ./shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
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
}
