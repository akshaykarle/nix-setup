{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pi;

  mkPiConfig = name: extraSettings: {
    "pi-${name}-settings" = {
      target = ".pi-${name}/agent/settings.json";
      text = builtins.toJSON (
        {
          defaultProvider = "anthropic";
          defaultModel = "claude-sonnet-4-6";
          packages = [ "npm:@akshaykarle/pi-tools" ];
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
  options.pi.profiles = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [
      "personal"
      "sahaj"
      "client"
    ];
    description = ''
      Which pi-agent profiles to configure. Each entry generates config files
      under ~/.pi-<profile>/agent/.
      Valid values: "personal", "sahaj", "client".
    '';
  };

  config.home.file = lib.mkMerge (
    lib.optionals (lib.elem "personal" cfg.profiles) [
      (mkPiConfig "personal" { })
    ]
    ++ lib.optionals (lib.elem "sahaj" cfg.profiles) [
      (mkPiConfig "sahaj" { })
    ]
    ++ lib.optionals (lib.elem "client" cfg.profiles) [
      (mkPiConfig "client" { })
    ]
  );
}
