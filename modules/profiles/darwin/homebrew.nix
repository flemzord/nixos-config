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
    mutableTaps = lib.mkDefault false;
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
      "libyaml"
      "xcodes"
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
      "jiratui"
      "cocoapods"
      "trufflehog"
      "yamllint"
      "specify"
      "worktrunk"
      "yakitrak/yakitrak/obsidian-cli"
      "CleverCloud/misc/mdr"
      "mobile-dev-inc/tap/maestro"
    ];
    casks = [
      # Shared across all Macs
      "1password"
      "1password-cli"
      "android-studio"
      "beeper"
      "bezel"
      "bruno"
      "bambu-studio"
      "cap"
      "chatgpt"
      "claude"
      "cleanshot"
      "comet"
      "cyberduck"
      "daisydisk"
      "discord"
      "elgato-capture-device-utility"
      "elgato-stream-deck"
      "figma"
      "google-chrome"
      "helium-browser"
      "httpie-desktop"
      "insta360-link-controller"
      "intellij-idea-ce"
      "iterm2"
      "linear-linear"
      "localcan"
      "loopback"
      "mattermost"
      "microsoft-teams"
      "ngrok"
      "notion"
      "notion-calendar"
      "obs"
      "obsidian"
      "postgres-unofficial"
      "proton-drive"
      "raycast"
      "rectangle"
      "screen-studio"
      "session-manager-plugin"
      "setapp"
      "signal"
      "sketch"
      "slack"
      "supacode"
      "superhuman"
      "switchresx"
      "tailscale-app"
      "thaw"
      "the-unarchiver"
      "Transmit"
      "transmission"
      "tuple"
      "ungoogled-chromium"
      "virtualbuddy"
      "visual-studio-code"
      "vlc"
      "whatsapp"
      "wispr-flow"
      "xcodes"
      "zed"
    ];
  };
}
