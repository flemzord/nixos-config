{ pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
  };
}
