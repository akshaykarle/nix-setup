{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Uninstall all programs not declared
      upgrade = true;
      extraFlags = [ "--force" ]; # Required by Homebrew 4.x+ when using --cleanup
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
    ];

    casks = [
      # Security-focused apps - keep updated
      {
        name = "1password";
        greedy = true;
      }
      {
        name = "brave-browser";
        greedy = true;
      }
      {
        name = "keybase";
        greedy = true;
      }
      {
        name = "signal";
        greedy = true;
      }
      # Standard apps - manual updates preferred
      "claude"
      "flycut"
      "iterm2"
      "ngrok"
      "rectangle"
    ];
  };
}
