{ pkgs, ... }:

let
  claudeBin = "/Users/flemzord/.local/bin/claude";
  vaultDir = "/Users/flemzord/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main";
  cronDir = "${vaultDir}/cron";
  logDir = "${cronDir}/logs";

  # Helper to create a launchd agent that runs claude with a prompt file
  mkClaudeCron = { name, promptFile, hour, minute, allowedTools ? "" }: {
    serviceConfig = {
      Label = "com.flemzord.claude-cron.${name}";
      ProgramArguments = [
        "/bin/bash"
        "-c"
        ''
          mkdir -p ${logDir}
          ${claudeBin} --model sonnet ${if allowedTools != "" then "--allowedTools '${allowedTools}'" else "--print"} -p "$(cat '${cronDir}/${promptFile}')" 2>>${logDir}/${name}.stderr.log
        ''
      ];
      WorkingDirectory = vaultDir;
      StartCalendarInterval = [
        { Hour = hour; Minute = minute; }
      ];
      StandardOutPath = "${logDir}/${name}.stdout.log";
      StandardErrorPath = "${logDir}/${name}.stderr.log";
      EnvironmentVariables = {
        HOME = "/Users/flemzord";
        PATH = "/Users/flemzord/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };
in
{
  launchd.user.agents = {
    claude-cron-resume = mkClaudeCron {
      name = "daily-claude-code-resume";
      promptFile = "daily-claude-code-resume.md";
      hour = 10;
      minute = 0;
      allowedTools = "Bash,Read,Write,Glob,Grep";
    };
  };
}
