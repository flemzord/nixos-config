{ pkgs }:

with pkgs;
let common-packages = import ../../pkgs/common/packages.nix { inherit pkgs; }; in
common-packages ++ [
  dockutil
  nixpkgs-fmt
  statix
  pre-commit
  postgresql_13
  act # run github actions locally
  alacritty
  awscli2
  bash-completion
  bat # A cat(1) clone with syntax highlighting
  difftastic
  coreutils
  dejavu_fonts
  du-dust
  flyctl
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
  jetbrains-mono
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
  pandoc
  pinentry
  python39
  python39Packages.virtualenv
  ripgrep
  sqlite
  ssm-session-manager-plugin
  zsh-powerlevel10k
  meslo-lgs-nf # Meslo Nerd Font patch for powerlevel10
  kubectx
  ctop
  httpie
  k6
  kubernetes-helm
  youtube-dl
]
