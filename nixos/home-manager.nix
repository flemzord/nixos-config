{ config, pkgs, lib, ... }:

let

  user = "flemzord";
  xdg_configHome  = "/home/${user}/.config";
  common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; lib = lib; };
  common-files = import ../common/files.nix {};

  polybar-user_modules = builtins.readFile (pkgs.substituteAll {
    src = ./config/polybar/user_modules.ini;
    packages = "${xdg_configHome}/polybar/bin/check-nixos-updates.sh";
    searchpkgs = "${xdg_configHome}/polybar/bin/search-nixos-updates.sh";
    launcher = "${xdg_configHome}/polybar/bin/launcher.sh";
    powermenu = "${xdg_configHome}/rofi/bin/powermenu.sh";
    calendar = "${xdg_configHome}/polybar/bin/popup-calendar.sh";
  });

  polybar-config = (pkgs.substituteAll {
      src = ./config/polybar/config.ini;
      font0 = "DejaVu Sans:size=12;3";
      font1 = "feather:size=12;3";
  });

  polybar-modules = builtins.readFile ./config/polybar/modules.ini;
  polybar-bars = builtins.readFile ./config/polybar/bars.ini;
  polybar-colors = builtins.readFile ./config/polybar/colors.ini;
in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    file = common-files // import ./files.nix { user = user; };
    stateVersion = "23.05";
  };

  # Use a dark theme
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };

  # Screen lock
  services.screen-locker = {
    enable = true;
    inactiveInterval = 30;
    lockCmd = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
    xautolock.extraOptions = [
      "Xautolock.killer: systemctl suspend"
    ];
  };

  # Auto mount devices
  services.udiskie.enable = true;

  services.polybar = {
    enable = true;
    config = polybar-config;
    extraConfig = polybar-bars + polybar-colors + polybar-modules + polybar-user_modules;
    package = pkgs.polybarFull;
    script = "polybar main &";
  };

  services.dunst = {
    enable = true;
    package = pkgs.dunst;
    settings = {
      global = {
      monitor = 0;
      follow = "mouse";
      border = 0;
      height = 400;
      width = 320;
      offset = "33x65";
      indicate_hidden = "yes";
      shrink = "no";
      separator_height = 0;
      padding = 32;
      horizontal_padding = 32;
      frame_width = 0;
      sort = "no";
      idle_threshold = 120;
      font = "Noto Sans";
      line_height = 4;
      markup = "full";
      format = "<b>%s</b>\n%b";
      alignment = "left";
      transparency = 10;
      show_age_threshold = 60;
      word_wrap = "yes";
      ignore_newline = "no";
      stack_duplicates = false;
      hide_duplicate_count = "yes";
      show_indicators = "no";
      icon_position = "left";
      icon_theme = "Adwaita-dark";
      sticky_history = "yes";
      history_length = 20;
      history = "ctrl+grave";
      browser = "google-chrome-stable";
      always_run_script = true;
      title = "Dunst";
      class = "Dunst";
      max_icon_size = 64;
    };
    };
  };

  programs = common-programs // {};

}
