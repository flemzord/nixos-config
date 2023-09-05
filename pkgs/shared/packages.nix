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
  ctop
  httpie
  k6
  kubectx
  kubernetes-helm
  supabase-cli
  terraform
  terragrunt
]
