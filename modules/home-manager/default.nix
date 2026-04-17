{
  self,
  config,
  pkgs,
  ...
}:
{
  # Required to get the fonts installed by home-manager to be picked up by OS.
  fonts.fontconfig.enable = true;

  home = {
    stateVersion = "23.11";

    packages = with pkgs; [
      # standard toolset
      curl
      diffutils
      findutils
      gnutar
      gawk
      git
      jq
      openssl
      ripgrep
      wget
      unixtools.watch

      # helpful tools
      tmux
      nix-output-monitor
      tailscale

      # IDEs & editors
      (if pkgs.stdenv.isDarwin then emacs.override { withNativeCompilation = false; } else emacs)
      vim

      # languages & tools related to them
      cmake
      ctags
      nixfmt-rfc-style
      nixpkgs-fmt
    ];

    file = {
      vundle = {
        source = builtins.fetchGit {
          url = "https://github.com/gmarik/Vundle.vim";
          rev = "5548a1a937d4e72606520c7484cd384e6c76b565";
        };
        target = ".vim/bundle/Vundle.vim";
        recursive = true;
      };
      emacs_d = {
        source = builtins.fetchGit {
          url = "https://github.com/syl20bnr/spacemacs";
          rev = "610d900767b35228b5a2eb79f2a8de9596a5a264";
        };
        target = ".emacs.d";
        recursive = true;
      };
      gitignore = {
        source = ../../dotfiles/gitignore.symlink;
        target = ".gitignore";
      };
      gitconfig = {
        source = ../../dotfiles/gitconfig.symlink;
        target = ".gitconfig";
      };
      spacemacs = {
        source = ../../dotfiles/spacemacs.symlink;
        target = ".spacemacs";
      };
      tmux = {
        source = ../../dotfiles/tmux.conf.symlink;
        target = ".tmux.conf";
      };
      vimrc = {
        source = ../../dotfiles/vimrc.symlink;
        target = ".vimrc";
      };
      lein = {
        source = ../../dotfiles/lein.symlink;
        target = ".lein";
        recursive = true;
      };
      claude-personal-statusline = {
        source = ../../dotfiles/claude-statusline.fish;
        target = ".claude-personal/statusline-command.fish";
        executable = true;
      };
      claude-personal-settings = {
        target = ".claude-personal/settings.json";
        text = builtins.toJSON {
          statusLine = {
            type = "command";
            command = "${config.home.homeDirectory}/.claude-personal/statusline-command.fish";
          };
        };
      };
      claude-sahaj-statusline = {
        source = ../../dotfiles/claude-statusline.fish;
        target = ".claude-sahaj/statusline-command.fish";
        executable = true;
      };
      claude-sahaj-settings = {
        target = ".claude-sahaj/settings.json";
        text = builtins.toJSON {
          statusLine = {
            type = "command";
            command = "${config.home.homeDirectory}/.claude-sahaj/statusline-command.fish";
          };
        };
      };
      claude-client-statusline = {
        source = ../../dotfiles/claude-statusline.fish;
        target = ".claude-client/statusline-command.fish";
        executable = true;
      };
      claude-client-settings = {
        target = ".claude-client/settings.json";
        text = builtins.toJSON {
          enabledPlugins = {
            "csharp-lsp@claude-plugins-official" = true;
          };
          alwaysThinkingEnabled = true;
          statusLine = {
            type = "command";
            command = "${config.home.homeDirectory}/.claude-client/statusline-command.fish";
          };
        };
      };

      # Supply chain security configurations
      npmrc = {
        target = ".npmrc";
        text = ''
          # Supply chain security
          min-release-age=7d
          ignore-scripts=true
          save-exact=true
          audit=true
          package-lock=true
          registry=https://registry.npmjs.org/
          email=npm requires email to be set but doesn't use the value
        ''
        + pkgs.lib.optionalString pkgs.stdenv.isDarwin ''

          # Azure DevOps Platforms registry
          //pkgs.dev.azure.com/AxiCore/Platforms/_packaging/Platforms/npm/registry/:username=''${AZURE_NPM_USERNAME}
          //pkgs.dev.azure.com/AxiCore/Platforms/_packaging/Platforms/npm/registry/:_password=''${AZURE_NPM_PASSWORD}
          //pkgs.dev.azure.com/AxiCore/Platforms/_packaging/Platforms/npm/:username=''${AZURE_NPM_USERNAME}
          //pkgs.dev.azure.com/AxiCore/Platforms/_packaging/Platforms/npm/:_password=''${AZURE_NPM_PASSWORD}
          //pkgs.dev.azure.com/AxiCore/Platforms/_packaging/Platforms/npm/:email=npm requires email to be set but doesn't use the value

          # Azure DevOps Portals registry
          //pkgs.dev.azure.com/AxiCore/Portals/_packaging/npm_axi_portals/npm/registry/:username=''${AZURE_NPM_USERNAME}
          //pkgs.dev.azure.com/AxiCore/Portals/_packaging/npm_axi_portals/npm/registry/:_password=''${AZURE_NPM_PASSWORD}
          //pkgs.dev.azure.com/AxiCore/Portals/_packaging/npm_axi_portals/npm/:username=''${AZURE_NPM_USERNAME}
          //pkgs.dev.azure.com/AxiCore/Portals/_packaging/npm_axi_portals/npm/:_password=''${AZURE_NPM_PASSWORD}
          //pkgs.dev.azure.com/AxiCore/Portals/_packaging/npm_axi_portals/npm/:email=npm requires email to be set but doesn't use the value

          # Accertify registry
          //repository.device.accertify.com/artifactory/api/npm/inmobile-npm/:email=''${ACCERTIFY_NPM_USERNAME}
          //repository.device.accertify.com/artifactory/api/npm/inmobile-npm/:_authToken=''${ACCERTIFY_NPM_TOKEN}
        '';
      };
      uv-config = {
        target = ".config/uv/uv.toml";
        text = ''
          # Supply chain protection: refuse packages newer than 7 days
          exclude-newer = "7 days"
        '';
      };
      maven-settings = {
        target = ".m2/settings.xml";
        text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">
            <profiles>
              <profile>
                <id>security-defaults</id>
                <repositories>
                  <repository>
                    <id>central</id>
                    <url>https://repo.maven.apache.org/maven2</url>
                    <releases>
                      <enabled>true</enabled>
                      <checksumPolicy>fail</checksumPolicy>
                    </releases>
                    <snapshots>
                      <enabled>false</enabled>
                    </snapshots>
                  </repository>
                </repositories>
                <pluginRepositories>
                  <pluginRepository>
                    <id>central</id>
                    <url>https://repo.maven.apache.org/maven2</url>
                    <releases>
                      <checksumPolicy>fail</checksumPolicy>
                    </releases>
                    <snapshots>
                      <enabled>false</enabled>
                    </snapshots>
                  </pluginRepository>
                </pluginRepositories>
              </profile>
            </profiles>
            <activeProfiles>
              <activeProfile>security-defaults</activeProfile>
            </activeProfiles>
          </settings>
        '';
      };
    };
  };

  programs = {
    home-manager = {
      enable = true;
      # path = "$HOME/.config/nixpkgs/modules/home-manager";
    };
    fish = {
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
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    go.enable = true;
    gpg.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
  };
}
