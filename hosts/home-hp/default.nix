{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/profiles/nixos/common.nix
    ./../../modules/services/octoprint.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "home-hp";

  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  services = {
    vscode-server.enable = true;
    xserver.enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "flemzord";
    };
    teamviewer.enable = true;
  };

  services.nixos-auto-update = {
    enable = true;
    hostname = "home-hp";
  };

  systemd.services.vscode-tunnel = {
    description = "VSCode SSH Tunnel";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.vscode}/bin/code tunnel --name=home --no-sleep";
    };
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    epiphany
    evince
  ];

  i18n.supportedLocales = [ "all" ];
  security.chromiumSuidSandbox.enable = true;

  system.stateVersion = "25.11";
}
