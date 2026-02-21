{ pkgs, config, ... }:

let user = "flemzord"; in
{

  imports = [
    ./../../modules/common/cachix.nix
    ./home-manager.nix
    #./../../modules/programs/aerospace.nix
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
    spaces.spans-displays = false; # For aerospace
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
    dock = {
      autohide = true;
      launchanim = false;
      magnification = false;
      mru-spaces = false;
      orientation = "bottom";

      persistent-apps = [
        "/Applications/Superhuman.app/"
        "/Applications/Google Chrome.app/"
        "/Applications/Dia.app/"
        "/Applications/Slack.app/"
        "/Applications/Mattermost.app/"
        "/Applications/Discord.app/"
        "/Applications/Beeper Desktop.app/"
        "/Applications/WhatsApp.app"
        "/Applications/Notion Calendar.app/"
        "/Applications/ChatGPT.app/"
        "/Applications/Obsidian.app/"
        "/Applications/iTerm.app/"
        "/Applications/Warp.app/"
        "/Applications/Zed.app/"
      ];
      persistent-others = [
        "/Users/${user}/Developer"
        "/Applications"
        "/Users/${user}/Downloads"
      ];
      show-recents = false;
      tilesize = 36;
    };

    finder = {
      AppleShowAllFiles = true;
      FXEnableExtensionChangeWarning = false;
      NewWindowTarget = "Home";
      ShowHardDrivesOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    WindowManager = {
      EnableTilingByEdgeDrag = false;
      EnableTilingOptionAccelerator = false;
      GloballyEnabled = false;
    };

    controlcenter = {
      BatteryShowPercentage = true;
      Bluetooth = true;
      Display = false;
      FocusModes = false;
      Sound = true;
    };

    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = false;
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticWindowAnimationsEnabled = false;
      NSTableViewDefaultSizeMode = 1;
      _HIHideMenuBar = false;
      "com.apple.keyboard.fnState" = false;
    };
    CustomUserPreferences = {
      # Enable ctrl+cmd+drag to move windows
      NSWindowShouldDragOnGesture = {
        value = true;
      };
    };
  };
      keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
