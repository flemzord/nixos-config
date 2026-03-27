{
  username,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./homebrew.nix
    ../../common/cachix.nix
  ];

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

  environment.systemPackages = import ../../common/packages.nix { inherit pkgs; };

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
      };
    };
  };
}
