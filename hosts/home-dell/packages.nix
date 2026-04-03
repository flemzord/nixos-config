{ pkgs }:

with pkgs; [
  vim
  k3s
  cloudflared
  claude-code
  codex
  ncdu

  # Dev PHP
  php84Packages.composer
  php
  xz

  # Dev tools NodeJS
  nodejs_22
  pnpm
  yarn
  bun
]
