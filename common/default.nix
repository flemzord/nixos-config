{ config, pkgs, ... }:

let
  emacsOverlaySha256 =
    #"1a3zyiha8vszaj04r14ryphri6cpbqk6inrbs7cybrc6m2kq8y17"
    "1xz956v01l3d1nzmcjbn016sn669mfq2wx9asgl85yyvvz7m7f38";
in
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };
  };
}
