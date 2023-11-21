{ pkgs }:

# These packages are shared across all my machines
with pkgs; [
  dockutil
  nixpkgs-fmt
  statix
  pre-commit
  difftastic
  coreutils
  flyctl
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
  libfido2
  neofetch
  nodePackages.npm
  nodejs
  ripgrep
  sqlite
  ssm-session-manager-plugin
  zsh-powerlevel10k
  ffmpeg

  syncthing # Sync files between machines

  # Dev tools
  git-subrepo
  go-task
  go
  gopls
  httpie
  k6
  kubectx
  kubernetes-helm
  supabase-cli
  terraform
  terragrunt
  direnv
]
