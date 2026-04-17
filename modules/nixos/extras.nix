{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    signal-desktop
    vlc
    dropbox
    keybase-gui
    ngrok
  ];

  # X11 / KDE Desktop Environment
  services.xserver = {
    enable = true;
    xkb.layout = "gb";
    xkb.variant = "";
  };
  services.libinput.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Printing
  services.printing.enable = true;

  # Sound (pipewire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Docker (dev machines only; daksh-home uses NixOS containers)
  virtualisation.docker.enable = true;
  users.users."${config.user.name}".extraGroups = [ "docker" ];
}
