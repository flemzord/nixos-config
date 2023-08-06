{ pkgs }:

# These packages are shared across all my machines
with pkgs; [
  btop
  htop
  glances
  direnv
  ffmpeg
  iftop
  jq
  yq
  openssh
  tree
  tmux
  unrar
  unzip
  wget
  zip
  watch
]
