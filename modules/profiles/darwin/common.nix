{
  username,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./homebrew.nix
  ];

  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    allowInsecure = false;
    allowUnsupportedSystem = true;
  };

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    isHidden = false;
    shell = pkgs.zsh;
  };


  time.timeZone = "Europe/Paris";
  ids.gids.nixbld = 350;

  nix = {
    settings.trusted-users = [ "@admin" username ];
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  security.pam.services.sudo_local = {
    enable = true;
    reattach = true;
    touchIdAuth = true;
  };

  system = {
    primaryUser = username;
    checks.verifyNixPath = false;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = lib.mkDefault true;
    };

    defaults = {
      spaces.spans-displays = false;
      dock.expose-group-apps = true;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

      dock = {
        autohide = true;
        launchanim = lib.mkDefault false;
        magnification = false;
        mru-spaces = false;
        show-recents = false;
        tilesize = lib.mkDefault 36;
        orientation = "bottom";
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
        AppleInterfaceStyleSwitchesAutomatically = lib.mkDefault false;
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSTableViewDefaultSizeMode = 1;
        _HIHideMenuBar = false;
        "com.apple.keyboard.fnState" = lib.mkDefault false;
      };

      CustomUserPreferences = {
        NSWindowShouldDragOnGesture = {
          value = true;
        };
        "com.apple.cameracontinuityd" = {
          Disabled = true;
        };
      };
    };
  };
}
