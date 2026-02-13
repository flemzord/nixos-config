{ pkgs }:

with pkgs; [
  ragenix
  nixpkgs-fmt
  nixd
  statix
  difftastic
  coreutils
  flyctl
  atuin
  fd
  fzf
  font-awesome
  gcc
  gh # github
  git-filter-repo
  gnupg
  hack-font
  jetbrains-mono
  killall
  libfido2
  neofetch
  ripgrep
  sqlite
  sshpass
  zsh-powerlevel10k
  ffmpeg
  curl
  wget
  turso-cli
  newman
  mosh
  htop

  # Dev tools
  krew
  k3d
  awscli2
  pipx
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
  postgresql_16
  natscli
  kind
  process-compose
  fluxcd
  ncdu
  pg_activity
  ipcalc

  # Dev tools NodeJS
  nodejs_22
  nodePackages.pnpm
  nodePackages.yarn
  bun

  # Dev tools Rust
  rustc
  cargo
  cmake

  # Dev PHP
  php84Packages.composer
  xz
  (pkgs.php84.buildEnv {
    extensions = { enabled, all }: enabled ++ (with all; [
      xdebug
      pcov
    ]);
    extraConfig = ''
      xdebug.mode=debug,coverage
      xdebug.client_host=127.0.0.1
      xdebug.client_port="9003"
      memory_limit = -1
    '';
  })

  # Dev Python
  uv
  python313
  python313Packages.click

  # AI tools
  claude-code # Via overlay from claude-code-nix
]
