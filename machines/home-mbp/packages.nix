{ pkgs }:

# These packages are shared across all my machines
with pkgs; [
  dockutil
  nixpkgs-fmt
  statix
  coreutils
  font-awesome
  gnupg
  hack-font
  home-manager
  jetbrains-mono
  killall
  ripgrep
  zsh-powerlevel10k
  curl
  wget

  # Dev Python
  pipx
  ffmpeg

 ]
