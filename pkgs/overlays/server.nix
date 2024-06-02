{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./../services/openssh.nix
      ./../programs/zsh.nix
      ./../programs/git.nix
      ./../services/tailscale.nix
    ];

  nix.optimise.automatic = true;

#  nixpkgs = {
#    config = {
#      allowUnfree = false;
#      allowBroken = false;
#      allowInsecure = false;
#      allowUnsupportedSystem = true;
#    };
#  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  networking.firewall = {
    enable = false;
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # Enable networking
  networking.networkmanager = {
    enable = true;
    unmanaged = [ "tailscale0" ];
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.flemzord = {
    isNormalUser = true;
    description = "flemzord";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  system.stateVersion = "24.05";
  users.users.root.openssh.authorizedKeys.keys = [ ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC33/UmOxIFBgPxxmr2qVqhN7wgdTLriKg4Em7MLi5KeIfWHs+Jqp7Fh6QDWwyOtRz8ARqtVlfZrO00xRAHx5UQkXmbd1iXeQgg7FPV+KuyAvAyfqciq0MJXFo5lIA9eO9TyFUKzC4dI/ayOubQDB8v5tCd+gYsW35eDrO5ueLi7ld2Q04lBO2mTNKoX0JUAd4+FYe9zkBXClh9ik0+F2IRBgG9HTVNqObUfXtpHp4iW0avXn7Syc4079rIkrwup7Swkxy1uo5nYeJSPHgnhDzjeCxzIal0UIDmPBHLAiuf8r2yWFb689jrmyfLYqN+o8QR2A5n+xQ5yxGmBDFKgkGN Flemzord@Flemzord-MBP.local'' ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCStDH1pzFpVJ1MU+7sfJma8lDUjlvL81Ue0CDlwkGv5EC513SgyLNITD5kenERzIrlIwl4D+VtMUnVKv7XLTJceZGtPl7Vzp+B27ZN9Ufb3zPzTOkbO3bYnSIKYuDH5YCxH9IRRM869JhPQ+q6KDjit1k1zRcaHR/vUtmtNeuRdySieHArVWJCBSW5pFw2F9iObaOiemi0yJ4fhYHraPqUyKAq6K0DNy23ZaMoa94f9iEtDm4dR5aK5Y6JaO0frhMKsEwMOLbz0RsY4LdAat6QZ27v1sfocRw1UaMYHdA2Jkk5/a1SqnQF5runYanbdvOBRdIjVejYxXDw2Ml8axqq0RON4hU77s0YAPCTvwfYYeLS1AnctcN/k3gvI9f35NV8JudXkOSp7Zkj5mOWYh3mtFhCkinOgNdxdYYVx8hDG0al+WKpeFDonvLP8dYrofMmdHC7Bjry+kiAaa5PszCOEoVNlGtIckzx2Q2TcFtPFGMC5vKkwD/AtNLTB4+OoXMcVpQVyyen4oy2jbd5MqWL2QvA2c0jqJusv70zu9Qxdfbac/IuJCTdS4KXYeh9Ij87RKAnyWffX3boKUahYj5jLyOvfxCfi3mN/smuL5WPk3RHuOAbtvnCkL8SQzM1i/Cf5cm9DTM5erpayUYign8ffG07ZLj9uiNWeUY4nZ4rGw=='' ];

  systemd.services.NetworkManager-wait-online.enable = false;
}
