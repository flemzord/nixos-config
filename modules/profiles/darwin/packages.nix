{ pkgs }:

# These packages are shared across all my machines
with pkgs; [
  ragenix
  nixpkgs-fmt
  nixd
  nvd
  statix
  difftastic
  semgrep
  coreutils
  flyctl
  atuin
  fd
  fzf
  font-awesome
  gcc
  apple-sdk
  gh # github
  git-filter-repo
  gnupg
  hack-font
  home-manager
  jetbrains-mono
  killall
  libfido2
  fastfetch
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
  ctop
  gnumake
  htop
  iftop
  zip
  screen
  httpie

  # Dev tools
  krew
  k3d
  awscli2
  pipx
  git-subrepo
  go-task
  httpie 
  zellij
  k6
  kubectx
  kubernetes-helm
  helm-docs
  supabase-cli
  tenv
  (direnv.overrideAttrs (_: {
    doCheck = false;
    doInstallCheck = false;
    checkPhase = "true";
    installCheckPhase = "true";
  }))
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
  pnpm
  yarn
  bun

  #turbo
  # bob # Removed: unmaintained upstream with vulnerable dependencies
  # devbox # Temporarily disabled due to cachix build issues
  # devenv # Temporarily disabled due to cachix build issues
  # Dev tools GoLang
  #go
  gopls
  # pulumi-bin
  # Dev tools Rust
  rustc
  rustfmt
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

  # CLI tools
  glow

  # AI tools
  claude-code # Via overlay from claude-code-nix
  gemini-cli
  # codex is managed via programs.codex in modules/home-manager/programs/codex.nix
]
