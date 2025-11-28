{ pkgs, config, ... }:

let user = "flemzord"; in
{

  imports = [
    ./../../modules/common/cachix.nix
    ./home-manager.nix
  ];

  # Agenix configuration
  age.identityPaths = [ "/Users/${user}/.ssh/id_rsa" ];

  age.secrets.ssh-config = {
    file = ./../../secrets/ssh-config.age;
    path = "/Users/${user}/.ssh/config";
    owner = user;
    mode = "0600";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };
    overlays = [
      (final: prev: {
        fish = prev.fish.overrideAttrs (old: {
          doCheck = false;
        });
        cachix = prev.cachix.overrideAttrs (old: {
          doCheck = false;
        });
      })
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";
  ids.gids.nixbld = 350;

  # Setup user, packages, programs
  nix = {
#    package = pkgs.lix;
    settings.trusted-users = [ "@admin" "${user}" ];


    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };


  # Load configuration that is shared across systems
  environment.systemPackages = import ../../modules/common/packages.nix { inherit pkgs; };

  system = {
    # Turn off NIX_PATH warnings now that we're using flakes
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 4;

    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 30;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = false;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
