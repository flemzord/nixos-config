{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.nixos-auto-update;
  autoUpdate = pkgs.writeShellApplication {
    name = "nixos-auto-update";
    runtimeInputs = [
      config.nix.package
      config.system.build.nixos-rebuild
      pkgs.coreutils
      pkgs.git
      pkgs.nvd
    ];
    text = ''
      set -euo pipefail

      git pull ${escapeShellArg cfg.remote} ${escapeShellArg cfg.branch}

      before="/nix/var/nix/profiles/$(readlink /nix/var/nix/profiles/system)"
      NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${cfg.hostname}"
      nvd diff "$before" /nix/var/nix/profiles/system
    '';
  };
in
{
  options.services.nixos-auto-update = {
    enable = mkEnableOption "automatic NixOS configuration updates from git";

    configPath = mkOption {
      type = types.str;
      default = "/etc/nixos";
      description = "Path to the NixOS configuration directory";
    };

    hostname = mkOption {
      type = types.str;
      description = "Hostname to use for nixos-rebuild (e.g., 'dev-server')";
    };

    branch = mkOption {
      type = types.str;
      default = "main";
      description = "Git branch to pull from";
    };

    remote = mkOption {
      type = types.str;
      default = "origin";
      description = "Git remote to pull from";
    };

    schedule = mkOption {
      type = types.str;
      default = "*-*-* 06:00:00";
      description = "Schedule in systemd timer format (default: daily at 6 AM)";
      example = "*-*-* 03:00:00";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nixos-auto-update = {
      description = "Automatic NixOS configuration update from git";
      serviceConfig = {
        Type = "oneshot";
        WorkingDirectory = cfg.configPath;
        ExecStart = "${autoUpdate}/bin/nixos-auto-update";
      };
    };

    systemd.timers.nixos-auto-update = {
      description = "Timer for automatic NixOS configuration update";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
      };
    };
  };
}
