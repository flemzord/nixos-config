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
  ripgrep
  sqlite
  ssm-session-manager-plugin
  zsh-powerlevel10k
  ffmpeg
  curl
  wget

  syncthing # Sync files between machines

  # Dev tools
  ansible
  git-subrepo
  go-task
  httpie
  k6
  kubectx
  kubernetes-helm
  helm-docs
  supabase-cli
  packer
  hcloud
  terraform
  terragrunt
  direnv
  nodePackages.pnpm
  yq
  jq
  k9s
  watch
  cilium-cli
  tree
  kustomize

  # Dev tools NodeJS
  nodejs_20
  nodePackages_latest.pnpm
  bun
  # Dev tools GoLang
  go
  gopls
  # Dev tools Rust
  rustc
  rustfmt
  cargo
]
