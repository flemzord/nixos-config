{ config, lib, pkgs, ... }:

{
  imports = [
    ../../services/openssh.nix
    ../../services/tailscale.nix
    ../../services/netbird.nix
    ../../services/docker.nix
    ../../services/nixos-auto-update.nix
    ../../programs/zsh.nix
    ../../programs/git.nix
  ];

  options.flemzord.githubTokenSecret.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Enable agenix-decrypted GitHub token (for flake fetching rate limits).
      Set to false during bootstrap on a host whose SSH host key is not yet
      registered in secrets.nix.
    '';
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    age.secrets = lib.mkIf config.flemzord.githubTokenSecret.enable {
      github-token = {
        file = ../../../secrets/github-token.age;
        mode = "0440";
        group = "nixbld";
      };
    };

    nix = {
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "@wheel" "flemzord" ];
      };
      extraOptions = lib.mkIf config.flemzord.githubTokenSecret.enable ''
        !include ${config.age.secrets.github-token.path}
      '';
    };

    # Locale
    time.timeZone = "Europe/Paris";
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
    console.keyMap = "fr";

    # Networking
    networking = {
      nameservers = lib.mkDefault [ "1.1.1.1" "9.9.9.9" ];
      firewall = {
        enable = false;
        checkReversePath = "loose";
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };
      networkmanager = {
        enable = true;
        unmanaged = [ "tailscale0" ];
      };
    };

    # Boot
    boot.loader.grub.configurationLimit = lib.mkDefault 2;

    # User
    users.users.flemzord = {
      isNormalUser = true;
      description = "flemzord";
      extraGroups = lib.mkDefault [ "networkmanager" "wheel" "docker" ];
    };

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC33/UmOxIFBgPxxmr2qVqhN7wgdTLriKg4Em7MLi5KeIfWHs+Jqp7Fh6QDWwyOtRz8ARqtVlfZrO00xRAHx5UQkXmbd1iXeQgg7FPV+KuyAvAyfqciq0MJXFo5lIA9eO9TyFUKzC4dI/ayOubQDB8v5tCd+gYsW35eDrO5ueLi7ld2Q04lBO2mTNKoX0JUAd4+FYe9zkBXClh9ik0+F2IRBgG9HTVNqObUfXtpHp4iW0avXn7Syc4079rIkrwup7Swkxy1uo5nYeJSPHgnhDzjeCxzIal0UIDmPBHLAiuf8r2yWFb689jrmyfLYqN+o8QR2A5n+xQ5yxGmBDFKgkGN Flemzord@Flemzord-MBP.local"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCStDH1pzFpVJ1MU+7sfJma8lDUjlvL81Ue0CDlwkGv5EC513SgyLNITD5kenERzIrlIwl4D+VtMUnVKv7XLTJceZGtPl7Vzp+B27ZN9Ufb3zPzTOkbO3bYnSIKYuDH5YCxH9IRRM869JhPQ+q6KDjit1k1zRcaHR/vUtmtNeuRdySieHArVWJCBSW5pFw2F9iObaOiemi0yJ4fhYHraPqUyKAq6K0DNy23ZaMoa94f9iEtDm4dR5aK5Y6JaO0frhMKsEwMOLbz0RsY4LdAat6QZ27v1sfocRw1UaMYHdA2Jkk5/a1SqnQF5runYanbdvOBRdIjVejYxXDw2Ml8axqq0RON4hU77s0YAPCTvwfYYeLS1AnctcN/k3gvI9f35NV8JudXkOSp7Zkj5mOWYh3mtFhCkinOgNdxdYYVx8hDG0al+WKpeFDonvLP8dYrofMmdHC7Bjry+kiAaa5PszCOEoVNlGtIckzx2Q2TcFtPFGMC5vKkwD/AtNLTB4+OoXMcVpQVyyen4oy2jbd5MqWL2QvA2c0jqJusv70zu9Qxdfbac/IuJCTdS4KXYeh9Ij87RKAnyWffX3boKUahYj5jLyOvfxCfi3mN/smuL5WPk3RHuOAbtvnCkL8SQzM1i/Cf5cm9DTM5erpayUYign8ffG07ZLj9uiNWeUY4nZ4rGw=="
    ];

    environment.systemPackages = import ./packages.nix { inherit pkgs; };

    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
