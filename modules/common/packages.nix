{ pkgs }:

# These packages are shared across all my machines
with pkgs; [
  wget
  curl
  htop
  iftop
  jq
  yq
  openssh
  tree
  unzip
  wget
  zip
  watch
  ctop
  gnumake
  git
  screen
]
