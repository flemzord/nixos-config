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
  ripgrep
  sqlite
  ssm-session-manager-plugin
  zsh-powerlevel10k
  ffmpeg
  curl
  wget
  tailscale
  syncthing # Sync files between machines

  # Dev tools
  krew
  k3d
  awscli2
  ansible
  pipx
  poetry
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
  tenv
  direnv
  yq
  jq
  k9s
  ko
  watch
  tree
  kustomize
  postgresql_16
  natscli
  kind
  process-compose
  fluxcd

  # Dev tools NodeJS
  nodejs_20
  nodePackages.pnpm
  nodePackages.yarn
  bun

  #turbo
  # Dev tools GoLang
  go
  gopls
  pulumi-bin
  # Dev tools Rust
  rustc
  rustfmt
  cargo

  # Dev PHP
  php83Packages.composer
  #php83
  #php83Extensions.xdebug
  xz
  (pkgs.php83.buildEnv {
    extensions = ({ enabled, all }: enabled ++ (with all; [
      xdebug
    ]));
    extraConfig = ''
      xdebug.mode=debug
      xdebug.client_host=127.0.0.1
      xdebug.client_port="9003"
    '';
  })
]
