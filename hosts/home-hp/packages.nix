{ pkgs }:

with pkgs;
let sharedPackages = import ./../../modules/common/packages.nix { inherit pkgs; }; in
sharedPackages ++ [
  slack
  discord
  obsidian
  teamviewer
  code-cursor
  windsurf
  vim
  ncdu
  vscode
  chromium
  appimage-run
  nodejs_20
  bun
  # Dev PHP
  php84Packages.composer
  xz
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
]
