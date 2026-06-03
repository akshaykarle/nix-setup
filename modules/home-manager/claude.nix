{
  config,
  lib,
  pkgs,
  ...
}:
let
  cavemanMarketplace = {
    caveman = {
      source = {
        source = "github";
        repo = "JuliusBrussee/caveman";
        ref = "v1.6.0";
      };
    };
  };

  mkClaudeConfig = name: extraSettings: {
    "claude-${name}-statusline" = {
      source = ../../dotfiles/claude-statusline.fish;
      target = ".claude-${name}/statusline-command.fish";
      executable = true;
    };
    "claude-${name}-settings" = {
      target = ".claude-${name}/settings.json";
      text = builtins.toJSON (
        {
          extraKnownMarketplaces = cavemanMarketplace;
          enabledPlugins = {
            "caveman@caveman" = true;
          };
          statusLine = {
            type = "command";
            command = "${config.home.homeDirectory}/.claude-${name}/statusline-command.fish";
          };
        }
        // extraSettings
      );
    };
  };

  # Writes claude_desktop_config.json into the per-profile Electron user-data-dir.
  # name must be capitalised (e.g. "Personal", "Sahaj", "Client") to match the
  # --user-data-dir path convention used by mkClaudeDesktopApp and the fish aliases.
  # mcpServers is an attrset of MCP server definitions, e.g.:
  #   { filesystem = { command = "npx"; args = [...]; }; }
  mkClaudeDesktopConfig = name: mcpServers: {
    "claude-desktop-${lib.toLower name}-config" = {
      target = "Library/Application Support/Claude-${name}/claude_desktop_config.json";
      text = builtins.toJSON {
        mcpServers = mcpServers;
      };
    };
  };

  # Creates a minimal macOS .app bundle in ~/Applications/ that launches the
  # Claude desktop app with --user-data-dir pointing at this profile's data dir.
  # Spotlight indexes ~/Applications so the app appears in Cmd+Space search.
  mkClaudeDesktopApp = name: {
    "claude-desktop-${lib.toLower name}-plist" = {
      target = "Applications/Claude-${name}.app/Contents/Info.plist";
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleName</key>
          <string>Claude-${name}</string>
          <key>CFBundleDisplayName</key>
          <string>Claude-${name}</string>
          <key>CFBundleIdentifier</key>
          <string>com.anthropic.claude-desktop-${lib.toLower name}</string>
          <key>CFBundleVersion</key>
          <string>1.0</string>
          <key>CFBundleExecutable</key>
          <string>Claude-${name}</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>NSHighResolutionCapable</key>
          <true/>
          <key>LSUIElement</key>
          <false/>
        </dict>
        </plist>
      '';
    };
    "claude-desktop-${lib.toLower name}-launcher" = {
      target = "Applications/Claude-${name}.app/Contents/MacOS/Claude-${name}";
      executable = true;
      text = ''
        #!/bin/bash
        exec /usr/bin/open -n -a "Claude" --args \
          --user-data-dir="$HOME/Library/Application Support/Claude-${name}"
      '';
    };
  };
in
{
  home.file =
    mkClaudeConfig "personal" { }
    // mkClaudeConfig "sahaj" { }
    // mkClaudeConfig "client" {
      enabledPlugins = {
        "csharp-lsp@claude-plugins-official" = true;
        "caveman@caveman" = true;
      };
      alwaysThinkingEnabled = true;
    }
    // mkClaudeDesktopConfig "Personal" { }
    // mkClaudeDesktopConfig "Sahaj" { }
    // mkClaudeDesktopConfig "Client" { }
    // mkClaudeDesktopApp "Personal"
    // mkClaudeDesktopApp "Sahaj"
    // mkClaudeDesktopApp "Client";
}
