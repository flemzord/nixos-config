{ pkgs }:

# These packages are shared across all my machines
with pkgs; [
  dockutil
  nixpkgs-fmt
  statix
  pre-commit
  difftastic
  coreutils
  fd
  fzf
  font-awesome
  gcc
  gh # github
  git-filter-repo
  gnupg
  hack-font
  home-manager
  jetbrains-mono
  killall
  ripgrep
  zsh-powerlevel10k
  curl
  wget


  # Dev PHP
  php83Packages.composer
  php83
  xz

  # Dev Python
  pipx
  ffmpeg

 ]
