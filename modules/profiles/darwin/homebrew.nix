{
  config,
  username,
  inputs,
  lib,
  ...
}:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    mutableTaps = true;
    autoMigrate = true;
    user = username;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "formancehq/homebrew-tap" = inputs.formancehq-cask;
      "loft-sh/homebrew-tap" = inputs.loftsh-cask;
      "earthly/homebrew-earthly" = inputs.earthly-cask;
      "koyeb/homebrew-tap" = inputs.koyeb-cask;
      "temporalio/homebrew-tap" = inputs.temporal-cask;
      "charmbracelet/homebrew-tap" = inputs.charmbracelet-cask;
      "darksworm/homebrew-tap" = inputs.darksworm-cask;
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = lib.mkDefault "zap";
      upgrade = true;
    };
    taps = builtins.attrNames config.nix-homebrew.taps ++ [
      "steveyegge/beads"
      "kamillobinski/thock"
      "yakitrak/yakitrak"
      "CleverCloud/misc"
    ];
    brews = [
      "dockutil"
      "pre-commit"
      "formancehq/tap/fctl"
      "koyeb/tap/koyeb"
      "loft-sh/tap/vcluster"
      "earthly/earthly/earthly"
      "temporalio/homebrew-tap/tcld"
      "steveyegge/beads/bd"
      "temporal"
      "helmfile"
      "rbenv"
      "tmux"
      "argocd"
      "cocoapods"
      "trufflehog"
      "yamllint"
      "specify"
      "worktrunk"
      "yakitrak/yakitrak/obsidian-cli"
      "CleverCloud/misc/mdr"
      "mobile-dev-inc/tap/maestro"
      "yt-dlp"
    ];
    casks = [
      # Shared across all Macs
      "1password"
      "1password-cli"
      "beeper"
      "bruno"
      "bambu-studio"
      "chatgpt"
      "claude"
      "comet"
      "discord"
      "figma"
      "google-chrome"
      "httpie-desktop"
      "intellij-idea-ce"
      "iterm2"
      "mattermost"
      "microsoft-teams"
      "ngrok"
      "notion"
      "notion-calendar"
      "obsidian"
      "postgres-unofficial"
      "raycast"
      "rectangle"
      "screen-studio"
      "session-manager-plugin"
      "setapp"
      "slack"
      "supacode"
      "superhuman"
      "tailscale-app"
      "thaw"
      "the-unarchiver"
      "transmission"
      "visual-studio-code"
      "whatsapp"
      "wispr-flow"
      "zed"
    ];
  };
}
