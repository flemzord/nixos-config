{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.paperclipai;
in
{
  options.services.paperclipai = {
    enable = mkEnableOption "PaperclipAI onboard service";

    workDir = mkOption {
      type = types.str;
      default = "/data/paperclipai";
      description = "Working directory for PaperclipAI";
    };
  };

  config = mkIf cfg.enable {
    age.secrets.openai-api-key = {
      file = ../../secrets/openai-api-key.age;
      owner = "paperclipai";
      group = "paperclipai";
      mode = "0400";
    };

    users.users.paperclipai = {
      isSystemUser = true;
      group = "paperclipai";
      home = cfg.workDir;
      createHome = true;
    };

    users.groups.paperclipai = { };

    services.postgresql = {
      ensureDatabases = [ "paperclipai" ];
      ensureUsers = [
        {
          name = "paperclipai";
          ensureDBOwnership = true;
        }
      ];
      authentication = "host paperclipai paperclipai 127.0.0.1/32 md5";
    };

    systemd.services.paperclipai-db-setup = {
      description = "Set PaperclipAI PostgreSQL password";
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "postgres";
        Group = "postgres";
        ExecStart = "${config.services.postgresql.package}/bin/psql -c \"ALTER USER paperclipai WITH PASSWORD 'paperclipai';\"";
      };
    };

    systemd.services.paperclipai = {
      description = "PaperclipAI";
      after = [ "network-online.target" "postgresql.service" "paperclipai-db-setup.service" ];
      wants = [ "network-online.target" ];
      requires = [ "postgresql.service" "paperclipai-db-setup.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.bash pkgs.coreutils pkgs.nodejs_22 pkgs.claude-code pkgs.codex pkgs.ripgrep ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 10;
        User = "paperclipai";
        Group = "paperclipai";
        WorkingDirectory = cfg.workDir;
        Environment = "DATABASE_URL=postgresql://paperclipai:paperclipai@127.0.0.1:5432/paperclipai";
        EnvironmentFile = config.age.secrets.openai-api-key.path;
        ExecStart = "${pkgs.nodejs_22}/bin/npx paperclipai run";
      };
    };
  };
}
