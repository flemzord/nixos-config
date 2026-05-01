{
  programs.aerospace = {
    enable = false;
    launchd.enable = true;
    launchd.keepAlive = true;

    settings = {
      after-startup-command = [ "layout accordion" ];
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 10;
      default-root-container-layout = "accordion";
      default-root-container-orientation = "horizontal";
      automatically-unhide-macos-hidden-apps = true;
      key-mapping.key-notation-to-key-code = {
        # Number row (AZERTY)
        "&" = "1";
        "é" = "2";
        "\"" = "3";
        "'" = "4";
        "(" = "5";
        "§" = "6";
        "è" = "7";
        "!" = "8";
        "ç" = "9";
        "à" = "0";
        ")" = "minus";
        minus = "equal";

        # Top row
        a = "q";
        z = "w";
        e = "e";
        r = "r";
        t = "t";
        y = "y";
        u = "u";
        i = "i";
        o = "o";
        p = "p";
        "^" = "leftSquareBracket";
        "$" = "rightSquareBracket";

        # Home row
        q = "a";
        s = "s";
        d = "d";
        f = "f";
        g = "g";
        h = "h";
        j = "j";
        k = "k";
        l = "l";
        m = "semicolon";
        "ù" = "quote";

        # Bottom row
        w = "z";
        x = "x";
        c = "c";
        v = "v";
        b = "b";
        n = "n";
        comma = "m";
        semicolon = "comma";
        colon = "period";
        "=" = "slash";
      };

      gaps = {
        inner = {
          horizontal = 12;
          vertical = 12;
        };
        outer = {
          left = 12;
          bottom = 12;
          top = 12;
          right = 12;
        };
      };

      mode.main.binding = {
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";
        alt-left = "focus left";
        alt-down = "focus down";
        alt-up = "focus up";
        alt-right = "focus right";
        ctrl-alt-shift-left = "move left";
        ctrl-alt-shift-down = "move down";
        ctrl-alt-shift-up = "move up";
        ctrl-alt-shift-right = "move right";
        "alt-shift-)" = "resize smart -50";
        alt-shift-minus = "resize smart +50";
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-m = "workspace M";
        alt-s = "workspace S";
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-m = "move-node-to-workspace M";
        alt-shift-s = "move-node-to-workspace S";
        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
        alt-shift-semicolon = "mode service";
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
      };

      # App-specific workspace assignments
      workspace-to-monitor-force-assignment = {
        "1" = [ "main" ];
        "2" = [ "main" ];
        "3" = [ "main" ];
        "4" = [ "main" ];
        "5" = [ "main" ];
        "6" = [ "main" ];
        "7" = [ "main" ];
        "M" = [
          "secondary"
          "main"
        ];
        "S" = [
          "secondary"
          "main"
        ];
      };

      on-window-detected = [
        {
          "if".app-id = "com.google.Chrome";
          run = [
            "move-node-to-workspace 1"
          ];
        }
        {
          "if".app-id = "ru.keepcoder.Telegram";
          run = [ "move-node-to-workspace M" ];
        }
        {
          "if".app-id = "net.whatsapp.WhatsApp";
          run = [ "move-node-to-workspace M" ];
        }
        {
          "if".app-id = "com.tinyspeck.slackmacgap";
          run = [ "move-node-to-workspace S" ];
        }
        {
          "if".app-id = "com.hnc.Discord";
          run = [ "move-node-to-workspace S" ];
        }
      ];
    };
  };

  services.jankyborders = {
    enable = true;
    settings = {
      active_color = "0xfffe8019";
      inactive_color = "0x00000000";
      hidpi = true;
      style = "round";
      width = 10.0;
      ax_focus = true;
      blacklist = "zed, slack";
    };
  };
}
