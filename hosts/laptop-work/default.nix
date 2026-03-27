{ username, ... }:
{
  networking.hostName = "laptop-work";

  imports = [
    ./home-manager.nix
    ./crons.nix
  ];

  # Agenix configuration
  age.identityPaths = [ "/Users/${username}/.ssh/id_rsa" ];
  age.secrets.ssh-config = {
    file = ./../../secrets/ssh-config.age;
    path = "/Users/${username}/.ssh/config";
    owner = username;
    mode = "0600";
  };

  nixpkgs.overlays = [
    (final: prev: {
      fish = prev.fish.overrideAttrs (old: { doCheck = false; });
      cachix = prev.cachix.overrideAttrs (old: { doCheck = false; });
    })
  ];

  system = {
    stateVersion = 4;

    keyboard.remapCapsLockToEscape = false;
    keyboard.remapCapsLockToControl = true;

    defaults = {
      dock = {
        orientation = "bottom";
        persistent-apps = [
          "/Applications/Superhuman.app/"
          "/Applications/Google Chrome.app/"
          "/Applications/Slack.app/"
          "/Applications/Mattermost.app/"
          "/Applications/Discord.app/"
          "/Applications/Beeper Desktop.app/"
          "/Applications/WhatsApp.app"
          "/Applications/Notion Calendar.app/"
          "/Applications/ChatGPT.app/"
          "/Applications/Claude.app/"
          "/Applications/Obsidian.app"
          "/Applications/iTerm.app/"
          "/Applications/Zed.app/"
        ];
        persistent-others = [
          "/Users/${username}/Developer"
          "/Applications"
          "/Users/${username}/Downloads"
        ];
      };
    };
  };
}
