{ pkgs, ... }:
{
  home.file = {
    pi-settings = {
      target = ".pi/agent/settings.json";
      text = builtins.toJSON {
        defaultProvider = "anthropic";
        defaultModel = "claude-sonnet-4-6";
        packages = [ "git:github.com/akshaykarle/pi-tools" ];
      };
    };
    pi-agents-md = {
      source = ../../dotfiles/pi-agents.md;
      target = ".pi/agent/AGENTS.md";
    };
    pi-sandbox-profile = pkgs.lib.mkIf pkgs.stdenv.isDarwin {
      source = ../../dotfiles/pi-sandbox.sb;
      target = ".pi/agent/pi-sandbox.sb";
    };
  };
}
