{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Uninstall all programs not declared
      upgrade = true;
    };
    global = { brewfile = true; };
    brews = [
      "coreutils"
      "rg"
      "ack"
      "autoconf"
      "readline"
      "findutils"
      "libpng"
      "freetype"
      "openssl"
      "gnu-tar"
      "libtool"
      "htop"
      "pkg-config"
      "libevent"
      "qt@5"
      "xz"
      "watch"
      "nmap"
      "wget"
      # required for fish- https://github.com/franciscolourenco/done
      "terminal-notifier"
      {
        name = "emacs-plus";
        start_service = true;
        args = [ "with-spacemacs-icon" "with-native-comp" ];
      }
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
      "d12frosted/emacs-plus"
    ];
    casks = [
      "brave-browser"
      "dropbox"
      "flycut"
      "iterm2"
      "keybase"
      "openoffice"
      "signal"
      "spectacle"
      "steam"
      "vlc"
    ];
  };
}
