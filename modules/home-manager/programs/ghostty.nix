{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      macos-titlebar-style = "transparent";
      window-padding-x = 12;
      window-padding-y = 12;
      working-directory = "home";
      window-inherit-working-directory = false;
      window-save-state = "never";
    };
  };
}
