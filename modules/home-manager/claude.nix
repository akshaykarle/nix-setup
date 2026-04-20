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
in
{
  home.file = {
    claude-personal-statusline = {
      source = ../../dotfiles/claude-statusline.fish;
      target = ".claude-personal/statusline-command.fish";
      executable = true;
    };
    claude-personal-settings = {
      target = ".claude-personal/settings.json";
      text = builtins.toJSON {
        extraKnownMarketplaces = cavemanMarketplace;
        enabledPlugins = {
          "caveman@caveman" = true;
        };
        statusLine = {
          type = "command";
          command = "${config.home.homeDirectory}/.claude-personal/statusline-command.fish";
        };
      };
    };
    claude-sahaj-statusline = {
      source = ../../dotfiles/claude-statusline.fish;
      target = ".claude-sahaj/statusline-command.fish";
      executable = true;
    };
    claude-sahaj-settings = {
      target = ".claude-sahaj/settings.json";
      text = builtins.toJSON {
        extraKnownMarketplaces = cavemanMarketplace;
        enabledPlugins = {
          "caveman@caveman" = true;
        };
        statusLine = {
          type = "command";
          command = "${config.home.homeDirectory}/.claude-sahaj/statusline-command.fish";
        };
      };
    };
    claude-client-statusline = {
      source = ../../dotfiles/claude-statusline.fish;
      target = ".claude-client/statusline-command.fish";
      executable = true;
    };
    claude-client-settings = {
      target = ".claude-client/settings.json";
      text = builtins.toJSON {
        extraKnownMarketplaces = cavemanMarketplace;
        enabledPlugins = {
          "csharp-lsp@claude-plugins-official" = true;
          "caveman@caveman" = true;
        };
        alwaysThinkingEnabled = true;
        statusLine = {
          type = "command";
          command = "${config.home.homeDirectory}/.claude-client/statusline-command.fish";
        };
      };
    };
  };
}
