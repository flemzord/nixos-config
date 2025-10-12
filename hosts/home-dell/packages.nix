{ pkgs }:

with pkgs;
let sharedPackages = import ./../../modules/common/packages.nix { inherit pkgs; }; in
sharedPackages ++ [
  vim
  k3s
  cloudflared
  claude-code
  ncdu

  # Dev PHP
  php84Packages.composer
  php
  xz

  # Dev tools NodeJS
  nodejs_22
  nodePackages.pnpm
  nodePackages.yarn
  bun
]
