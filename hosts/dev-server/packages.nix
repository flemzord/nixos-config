{ pkgs }:

# Core development packages for remote dev server
# Focused on language runtimes, build tools, and essential utilities
# Excludes cloud/k8s tools (add per-project via devenv/direnv as needed)

with pkgs; [
  # Language Runtimes & Package Managers
  nodejs_22
  nodePackages.pnpm
  nodePackages.yarn
  bun
  python313
  poetry
  uv
  php84Packages.composer
  (pkgs.php84.buildEnv {
    extensions = { enabled, all }: enabled ++ (with all; [
      xdebug
    ]);
    extraConfig = ''
      xdebug.mode=debug
      xdebug.client_host=127.0.0.1
      xdebug.client_port="9003"
    '';
  })
  rustc
  cargo

  # Build Tools
  cmake
  gnumake
  gcc

  # Version Control
  git-filter-repo
  gh
  difftastic

  # Development Environment
  direnv
  devenv
  devbox
  go-task
  process-compose
  mosh

  # Essential Utilities
  jq
  yq
  ripgrep
  fd
  fzf
  htop
  ncdu
  sqlite
  curl
  wget
]
