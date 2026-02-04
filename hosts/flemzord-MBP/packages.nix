{ pkgs }:

# These packages are shared across all my machines
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
  home-manager
  jetbrains-mono
  killall
  libfido2
  neofetch
  ripgrep
  sqlite
  sshpass
  # ssm-session-manager-plugin # TODO: broken vendoring upstream
  zsh-powerlevel10k
  ffmpeg
  curl
  wget
  turso-cli
  newman
  mosh

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

  #turbo
  # bob # Removed: unmaintained upstream with vulnerable dependencies
  # devbox # Temporarily disabled due to cachix build issues
  # devenv # Temporarily disabled due to cachix build issues
  # Dev tools GoLang
  #go
  #gopls
  # pulumi-bin
  # Dev tools Rust
  rustc
  #rustfmt
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
  # poetry # Temporarily disabled: pbs-installer version conflict in nixpkgs
]
