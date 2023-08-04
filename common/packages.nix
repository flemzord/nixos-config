{ pkgs }:

# These packages are shared across all my machines
with pkgs; [
  act # run github actions locally
  alacritty
  awscli2
  bash-completion
  bat # A cat(1) clone with syntax highlighting
  btop
  htop
  glances
  coreutils
  difftastic
  dejavu_fonts
  du-dust
  flyctl
  ffmpeg
  fd
  fzf
  font-awesome
  gcc
  gh # github
  git-filter-repo
  gnupg
  go
  gopls
  hack-font
  home-manager
  hunspell
  iftop
  jetbrains-mono
  jq
  yq

  # This is broken on MacOS for now
  # https://github.com/NixOS/nixpkgs/issues/172165 
  # keepassxc

  killall
  libfido2
  neofetch
  nodePackages.live-server
  nodePackages.nodemon
  nodePackages.prettier
  nodePackages.npm
  nodejs
  noto-fonts
  noto-fonts-emoji
  openssh
  pandoc
  pinentry
  python39
  python39Packages.virtualenv
  ripgrep
  sqlite
  ssm-session-manager-plugin
  tree
  tmux
  unrar
  unzip
  wget
  zip
  zsh-powerlevel10k
  meslo-lgs-nf # Meslo Nerd Font patch for powerlevel10
]
