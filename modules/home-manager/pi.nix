{ pkgs, ... }:
let
  mkPiConfig = name: extraSettings: {
    "pi-${name}-settings" = {
      target = ".pi-${name}/agent/settings.json";
      text = builtins.toJSON (
        {
          defaultProvider = "anthropic";
          defaultModel = "claude-sonnet-4-6";
          packages = [ "git:github.com/akshaykarle/pi-tools" ];
        }
        // extraSettings
      );
    };
    "pi-${name}-agents-md" = {
      source = ../../dotfiles/pi-agents.md;
      target = ".pi-${name}/agent/AGENTS.md";
    };
  };
in
{
  home.file = mkPiConfig "personal" { } // mkPiConfig "sahaj" { } // mkPiConfig "client" { };
}
