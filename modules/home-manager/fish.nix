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
      pi-sandboxed = ''
        if not set -q PI_CODING_AGENT_DIR
          echo "ERROR: PI_CODING_AGENT_DIR is not set. Use pi-personal, pi-sahaj, or pi-client." >&2
          return 1
        end
        set -l pi_dir $PI_CODING_AGENT_DIR

        # Secret env vars to strip from the pi process
        set -l secret_vars \
          ANTHROPIC_API_KEY OPENAI_API_KEY GITHUB_TOKEN GH_TOKEN \
          AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN \
          AZURE_NPM_PASSWORD AZURE_NPM_USERNAME ACCERTIFY_NPM_TOKEN \
          NPM_TOKEN DATABASE_URL PRIVATE_KEY SSH_PRIVATE_KEY \
          GOOGLE_API_KEY SLACK_TOKEN DISCORD_TOKEN \
          SENDGRID_API_KEY STRIPE_SECRET_KEY DOPPLER_TOKEN \
          VAULT_TOKEN TAILSCALE_AUTH_KEY

        if test (uname) = "Linux"
          set -l bwrap_args \
            --ro-bind /nix /nix \
            --ro-bind /etc /etc \
            --ro-bind /run /run \
            --dev /dev \
            --proc /proc \
            --tmpfs /tmp \
            --tmpfs $HOME \
            --bind $pi_dir $pi_dir \
            --ro-bind $HOME/.gitconfig $HOME/.gitconfig \
            --ro-bind $HOME/.gitignore $HOME/.gitignore \
            --bind (pwd) (pwd) \
            --chdir (pwd) \
            --unshare-pid \
            --new-session \
            --die-with-parent

          for var in $secret_vars
            if set -q $var
              set bwrap_args $bwrap_args --unsetenv $var
            end
          end

          exec bwrap $bwrap_args -- pi $argv

        else if test (uname) = "Darwin"
          set -l env_args
          for var in $secret_vars
            if set -q $var
              set env_args $env_args -u $var
            end
          end

          set -l sandbox_profile "$pi_dir/agent/pi-sandbox.sb"
          if test -f $sandbox_profile
            exec env $env_args sandbox-exec -D "CWD=(pwd)" -f $sandbox_profile pi $argv
          else
            echo "WARNING: Seatbelt profile not found, running pi without OS sandbox"
            exec env $env_args pi $argv
          end

        else
          echo "WARNING: No sandbox available on this OS"
          exec pi $argv
        end
      '';
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
      pi-personal = "PI_CODING_AGENT_DIR=~/.pi-personal pi-sandboxed";
      pi-sahaj = "PI_CODING_AGENT_DIR=~/.pi-sahaj pi-sandboxed";
      pi-client = "PI_CODING_AGENT_DIR=~/.pi-client pi-sandboxed";
    };
  };
}
