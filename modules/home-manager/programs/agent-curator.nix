{ config, lib, pkgs, ... }:

let
  cfg = config.programs.agent-curator;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  logDir = "${config.home.homeDirectory}/.local/state/agent-curator";

  agentCurator = pkgs.writeShellApplication {
    name = "agent-curator";
    runtimeInputs = [
      pkgs.python3
    ];
    text = ''
      exec ${pkgs.python3}/bin/python3 ${./agent-curator/agent_curator.py} \
        --config "''${AGENT_CURATOR_CONFIG:-$HOME/.config/agent-curator/config.json}" \
        "$@"
    '';
  };

  json = pkgs.formats.json { };
in
{
  options.programs.agent-curator = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install a local read-only curator for Claude/Codex durable knowledge files.";
    };

    repoRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/nixos-config";
      description = "Local nixos-config checkout used as the declarative source of truth.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.local/share/agent-curator";
      description = "Runtime output directory for indexes, reports, and proposals. This must stay outside git.";
    };

    maxFileBytes = lib.mkOption {
      type = lib.types.int;
      default = 300000;
      description = "Maximum allowlisted file size to read.";
    };

    autoManagedSkillPrefixes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "agent-" ];
      description = "Skill name prefixes that agent-curator may treat as safe for automatic edits.";
    };

    schedule = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run agent-curator scan periodically.";
      };

      hour = lib.mkOption {
        type = lib.types.int;
        default = 15;
        description = "Hour of day for the scheduled scan.";
      };

      minute = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = "Minute of the hour for the scheduled scan.";
      };

      runAtLoad = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Run a scan when the launchd agent is loaded.";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion =
            let
              normalizedRepoRoot = lib.removeSuffix "/" cfg.repoRoot;
            in
            cfg.dataDir != normalizedRepoRoot && !(lib.hasPrefix "${normalizedRepoRoot}/" cfg.dataDir);
          message = "programs.agent-curator.dataDir must not be inside programs.agent-curator.repoRoot.";
        }
        {
          assertion = cfg.schedule.hour >= 0 && cfg.schedule.hour <= 23;
          message = "programs.agent-curator.schedule.hour must be between 0 and 23.";
        }
        {
          assertion = cfg.schedule.minute >= 0 && cfg.schedule.minute <= 59;
          message = "programs.agent-curator.schedule.minute must be between 0 and 59.";
        }
      ];

      home.packages = [
        agentCurator
      ];

      xdg.configFile."agent-curator/config.json".source = json.generate "agent-curator-config.json" {
        repo_root = cfg.repoRoot;
        data_dir = cfg.dataDir;
        max_file_bytes = cfg.maxFileBytes;
        auto_managed_skill_prefixes = cfg.autoManagedSkillPrefixes;
      };

      # Runtime reports can include local paths and private workflow names. Keep
      # them reviewable locally but untracked if the directory is ever moved.
      home.file.".local/share/agent-curator/.gitignore".text = ''
        *
        !.gitignore
      '';
    }

    (lib.mkIf cfg.schedule.enable {
      home.file.".local/state/agent-curator/.keep".text = "";
    })

    (lib.mkIf (cfg.schedule.enable && isDarwin) {
      launchd.agents.agent-curator-scan = {
        enable = true;
        config = {
          ProgramArguments = [
            "${agentCurator}/bin/agent-curator"
            "scan"
          ];
          EnvironmentVariables = {
            HOME = config.home.homeDirectory;
          };
          StartCalendarInterval = [
            {
              Hour = cfg.schedule.hour;
              Minute = cfg.schedule.minute;
            }
          ];
          RunAtLoad = cfg.schedule.runAtLoad;
          StandardOutPath = "${logDir}/launchd.out.log";
          StandardErrorPath = "${logDir}/launchd.err.log";
        };
      };
    })

    (lib.mkIf (cfg.schedule.enable && !isDarwin) {
      systemd.user.services.agent-curator-scan = {
        Unit = {
          Description = "Scan Claude/Codex durable knowledge files";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${agentCurator}/bin/agent-curator scan";
        };
      };

      systemd.user.timers.agent-curator-scan = {
        Unit = {
          Description = "Periodic agent-curator scan";
        };
        Timer = {
          Unit = "agent-curator-scan.service";
          OnCalendar = "*-*-* ${toString cfg.schedule.hour}:${toString cfg.schedule.minute}:00";
          Persistent = true;
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    })
  ]);
}
