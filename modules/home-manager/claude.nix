{ config, pkgs, ... }:
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
    };
}
