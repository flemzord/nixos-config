{ pkgs }:

with pkgs;
let shared-packages = import ./../../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  vim
  k3s
  cloudflared
  claude-code

  # Dev PHP
  php84Packages.composer
  xz

  # Dev tools NodeJS
  nodejs_22
  nodePackages.pnpm
  nodePackages.yarn
  bun
]
