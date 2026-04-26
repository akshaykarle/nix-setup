{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [
      {
        name = "bass";
        src = bass.src;
      }
      {
        name = "colored-man-pages";
        src = colored-man-pages.src;
      }
      {
        name = "done";
        src = done.src;
      }
      {
        name = "z";
        src = z.src;
      }
    ];
    shellInit = ''
      set fish_greeting

      # Source custom scripts
      if test -e $HOME/.config/fish/custom
          source $HOME/.config/fish/custom/*.fish
      end

      # Source secret envs :
      if test -e $HOME/.config/fish/secret.fish
          source $HOME/.config/fish/secret.fish
      end

      # Add homebrew to the PATH:
      if test -e /opt/homebrew/bin/brew
          eval "$(/opt/homebrew/bin/brew shellenv)"
      end

      # Go module security: ensure checksum verification is never accidentally disabled
      set -gx GONOSUMCHECK ""
      set -gx GOFLAGS "-mod=readonly"

      # npm: use nix-managed global config; leave ~/.npmrc writable for `npm login`
      set -gx NPM_CONFIG_GLOBALCONFIG "$HOME/.config/npm/npmrc"
    '';
    functions = {
      wifi-password-finder = "security find-generic-password -gwa $1";
      generate-new-mac-address = "openssl rand -hex 6 | sed 's/(..)/1:/g; s/.$//' | xargs sudo ifconfig $1 ether";
      global-search-replace = "ack $1 -l --print0 | xargs -0 sed -i '' \"s/$1/$2/g\"";
    };
    shellAliases = {
      g = "git";
      d = "docker";
      k = "kubectl";
      tf = "terraform";
      gh = "open (git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#http://#' -e 's@com:@com/@')| head -n1";
      claude-personal = "CLAUDE_CONFIG_DIR=~/.claude-personal claude";
      claude-sahaj = "CLAUDE_CONFIG_DIR=~/.claude-sahaj claude";
      claude-client = "CLAUDE_CONFIG_DIR=~/.claude-client claude";
      pi-personal = "PI_CODING_AGENT_DIR=~/.pi-personal pi";
      pi-sahaj = "PI_CODING_AGENT_DIR=~/.pi-sahaj pi";
      pi-client = "PI_CODING_AGENT_DIR=~/.pi-client pi";
    };
  };
}
