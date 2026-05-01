{ config, lib, pkgs, ... }:

let
  cfg = config.services.hermes-agent;
  hermes = "${cfg.package}/bin/hermes";
in
{
  services.hermes-agent.settings = {
    kanban = {
      dispatch_in_gateway = true;
      dispatch_interval_seconds = 60;
    };

    dashboard.kanban = {
      include_archived_by_default = false;
      lane_by_profile = true;
      render_markdown = true;
    };
  };

  systemd.services.hermes-dashboard = lib.mkIf cfg.enable {
    description = "Hermes Agent Dashboard";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "hermes-agent.service"
    ];
    wants = [ "network-online.target" ];

    environment = {
      HOME = cfg.stateDir;
      HERMES_HOME = "${cfg.stateDir}/.hermes";
      HERMES_MANAGED = "true";
      MESSAGING_CWD = cfg.workingDirectory;
    };

    serviceConfig = {
      User = cfg.user;
      Group = cfg.group;
      WorkingDirectory = cfg.workingDirectory;
      ExecStart = "${hermes} dashboard --host 127.0.0.1 --port 9119 --no-open";
      Restart = "always";
      RestartSec = 5;
      UMask = "0007";

      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = false;
      ReadWritePaths = [
        cfg.stateDir
        cfg.workingDirectory
      ];
      PrivateTmp = true;
    };

    path = [
      cfg.package
      pkgs.bash
      pkgs.coreutils
      pkgs.git
    ] ++ cfg.extraPackages;
  };
}
