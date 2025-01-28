{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Uninstall all programs not declared
      upgrade = true;
    };
    global = {
      brewfile = true;
    };
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
        args = [
          "with-spacemacs-icon"
          "with-native-comp"
        ];
      }
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/services"
      "d12frosted/emacs-plus"
    ];
    casks = [
      {
        name = "1password";
        greedy = true;
      }
      {
        name = "brave-browser";
        greedy = true;
      }
      {
        name = "dropbox";
        greedy = true;
      }
      {
        name = "flycut";
        greedy = true;
      }
      {
        name = "iterm2";
        greedy = true;
      }
      {
        name = "keybase";
        greedy = true;
      }
      {
        name = "openoffice";
        greedy = true;
      }
      {
        name = "signal";
        greedy = true;
      }
      {
        name = "rectangle";
        greedy = true;
      }
      {
        name = "steam";
        greedy = true;
      }
      {
        name = "vlc";
        greedy = true;
      }
    ];
  };
}
