{ pkgs }:

with pkgs;
let sharedPackages = import ./../../modules/common/packages.nix { inherit pkgs; }; in
sharedPackages ++ [
  vim
  ncdu
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
