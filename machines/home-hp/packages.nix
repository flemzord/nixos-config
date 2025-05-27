{ pkgs }:

with pkgs;
let shared-packages = import ./../../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  slack
  discord
  obsidian
  teamviewer
  code-cursor
  windsurf
  vim
  vscode
  chromium
  appimage-run
  nodejs_20
  bun
  # Dev PHP
  php84Packages.composer
  xz
  (pkgs.php84.buildEnv {
    extensions = ({ enabled, all }: enabled ++ (with all; [
      xdebug
    ]));
    extraConfig = ''
      xdebug.mode=debug
      xdebug.client_host=127.0.0.1
      xdebug.client_port="9003"
    '';
  })
]
