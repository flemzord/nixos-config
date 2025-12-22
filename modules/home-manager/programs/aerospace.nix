{
  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    launchd.keepAlive = true;

    settings = {
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 0;
      default-root-container-layout = "accordion";
      default-root-container-orientation = "horizontal";
      automatically-unhide-macos-hidden-apps = true;
      key-mapping.preset = "qwerty";
      gaps = {
        inner.horizontal = 0;
        inner.vertical = 0;
        outer.left = 0;
        outer.bottom = 0;
        outer.top = 0;
        outer.right = 0;
      };
      # AZERTY-friendly keybindings
      mode.main.binding = {
        # Layout
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        # Focus (vim-style - same physical keys on AZERTY)
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        # Move windows
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # Resize (letter keys work on all layouts)
        alt-d = "resize smart -50";
        alt-shift-d = "resize smart -200";
        alt-f = "resize smart +50";
        alt-shift-f = "resize smart +200";

        # Workspaces
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-m = "workspace M";

        # Move to workspace
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-m = "move-node-to-workspace M";

        # Workspace navigation
        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

        # Monitor focus (AZERTY-friendly: i/o instead of [/])
        alt-i = "focus-monitor left";
        alt-o = "focus-monitor right";

        # Service mode (AZERTY-friendly: s instead of ;)
        alt-shift-s = "mode service";
      };

      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        r = [
          "flatten-workspace-tree"
          "mode main"
        ];
        f = [
          "layout floating tiling"
          "mode main"
        ];
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];
        alt-shift-h = [
          "join-with left"
          "mode main"
        ];
        alt-shift-j = [
          "join-with down"
          "mode main"
        ];
        alt-shift-k = [
          "join-with up"
          "mode main"
        ];
        alt-shift-l = [
          "join-with right"
          "mode main"
        ];
      };

      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = "secondary";
        "6" = "secondary";
        "7" = "secondary";
        "8" = "secondary";
        "M" = "secondary";
      };

      on-window-detected = [
        {
          "if".app-id = "com.hnc.Discord";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.MobileSMS";
          run = "layout floating";
        }
        {
          "if".app-id = "net.whatsapp.WhatsApp";
          run = "layout floating";
        }
        {
          "if".app-id = "com.tinyspeck.slackmacgap";
          run = "layout floating";
        }
        {
          "if".app-id = "com.1password.1password";
          run = "layout floating";
        }
        {
          "if".app-id = "com.anthropic.claudefordesktop";
          run = [
            "move-node-to-workspace 1"
            "resize width -400"
          ];
        }
        {
          "if".app-id = "com.todesktop.230313mzl4w4u92"; # Cursor
          run = "move-node-to-workspace 1";
        }
        {
          "if".app-id = "com.google.Chrome";
          run = "move-node-to-workspace 1";
        }
      ];
    };
  };
}