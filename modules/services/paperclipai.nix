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

    openaiApiKeyFile = mkOption {
      type = types.str;
      default = config.age.secrets.openai-api-key.path;
      description = "Environment file containing OPENAI_API_KEY for Codex local adapter.";
    };
  };

  config = mkIf cfg.enable {
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
      after = [ "postgresql.service" "postgresql-setup.service" ];
      requires = [ "postgresql.service" "postgresql-setup.service" ];
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
        Environment = [
          "CODEX_HOME=${cfg.workDir}/.codex"
          "DATABASE_URL=postgresql://paperclipai:paperclipai@127.0.0.1:5432/paperclipai"
          "HOME=${cfg.workDir}"
          "PAPERCLIP_HOME=${cfg.workDir}"
        ];
        EnvironmentFile = cfg.openaiApiKeyFile;
        ExecStart = "${pkgs.nodejs_22}/bin/npx --yes paperclipai run";
      };
    };
  };
}
