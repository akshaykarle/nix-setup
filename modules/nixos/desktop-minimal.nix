{ config, pkgs, ... }:
{
  # Sway tiling Wayland compositor
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # greetd minimal login manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  # Minimal fonts for browser rendering
  fonts.packages = with pkgs; [ noto-fonts ];

  # Foot terminal (lightweight Wayland-native terminal)
  environment.systemPackages = with pkgs; [
    foot
  ];
}
