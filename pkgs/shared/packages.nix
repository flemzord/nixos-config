{ pkgs }:

# These packages are shared across all my machines
with pkgs; [
  btop
  htop
  glances
  iftop
  jq
  yq
  openssh
  tree
  unrar
  unzip
  wget
  zip
  watch
  ctop
]
