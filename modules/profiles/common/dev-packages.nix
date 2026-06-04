{ lib, pkgs }:

with pkgs;
let
  direnvNoChecks = direnv.overrideAttrs (_: {
    doCheck = false;
    doInstallCheck = false;
    checkPhase = "true";
    installCheckPhase = "true";
  });

  pipxNoChecks = pipx.overridePythonAttrs (_: {
    doCheck = false;
  });

  semgrepNoChecks = semgrep.overridePythonAttrs (_: {
    doCheck = false;
  });

  pythonDev = python313.withPackages (ps: with ps; [
    click
    pyyaml
  ]);
in
[
  ragenix
  nixpkgs-fmt
  nixd
  nvd
  statix
  deadnix
  difftastic
  semgrepNoChecks
  coreutils
  flyctl
  atuin
  fd
  fzf
  font-awesome
  gcc
  gh
  git-filter-repo
  gnupg
  hack-font
  home-manager
  jetbrains-mono
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
  pipxNoChecks
  git-subrepo
  go-task
  zellij
  k6
  kubectx
  kubernetes-helm
  helm-docs
  supabase-cli
  tenv
  direnvNoChecks
  yq
  jq
  jsonnet
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

  # Dev tools GoLang
  gopls

  # Dev tools Rust
  rustc
  rustfmt
  cargo
  cmake

  # Dev Python
  uv
  pythonDev

  # CLI tools
  herdr
  glow

  # AI tools
  claude-code
  gemini-cli
]
++ lib.optionals stdenv.isDarwin [
  apple-sdk
  banqline
  gitnexus
  killall
  qmd
]
++ lib.optionals stdenv.isLinux [
  git
  openssh
  unzip
  codex
]
