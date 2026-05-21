{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;

    # Editor options (migrated from vimrc)
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      spell = true;
      smartcase = true;
      ignorecase = true;
      hidden = true;
      background = "dark";
      autoindent = true;
      backspace = "indent,eol,start"; # from vimrc: set backspace=indent,eol,start
      showcmd = true; # from vimrc: set showcmd
    };

    # Leader key (Space, like spacemacs)
    globals.mapleader = " ";

    # Colorscheme — tokyonight-night is closest to spacemacs-dark
    colorschemes.tokyonight = {
      enable = true;
      settings.style = "night";
    };

    # Formatter/linter binaries — scoped to neovim subprocess only (not global shell)
    extraPackages = with pkgs; [
      black # Python formatter
      ruff # Python linter
      nodePackages.prettier # JS/TS/JSON/YAML/MD formatter
      nodePackages.eslint # JS/TS linter
      shellcheck # Shell linter
      shfmt # Shell formatter
      # nixfmt-rfc-style is already in global home.packages — no need to duplicate here
    ];

    plugins = {
      # ── File tree ──────────────────────────────────────────────────────────
      # Replaces NERDTree + Spacemacs neotree layer
      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          window.width = 30;
        };
      };

      # ── Fuzzy finding ──────────────────────────────────────────────────────
      # Replaces CtrlP + Spacemacs Helm layer
      telescope.enable = true;

      # ── Which-key popup ────────────────────────────────────────────────────
      # Spacemacs-style SPC leader menus
      which-key = {
        enable = true;
        settings.spec = [
          {
            __unkeyed = "<leader>f";
            group = "file/find";
          }
          {
            __unkeyed = "<leader>b";
            group = "buffer";
          }
          {
            __unkeyed = "<leader>g";
            group = "git";
          }
          {
            __unkeyed = "<leader>c";
            group = "code/LSP";
          }
          {
            __unkeyed = "<leader>t";
            group = "terminal";
          }
          {
            __unkeyed = "<leader>x";
            group = "test";
          }
          {
            __unkeyed = "<leader>w";
            group = "window";
          }
          # <leader>e is a direct keymap (toggle tree), not a group — no sub-keys
        ];
      };

      # ── LSP ────────────────────────────────────────────────────────────────
      # Replaces YouCompleteMe + syntastic + tide
      # nixvim auto-includes the LSP server binaries — no extraPackages needed
      lsp = {
        enable = true;
        servers = {
          pyright.enable = true; # Python
          ts_ls.enable = true; # TypeScript / Node
          nil_ls.enable = true; # Nix
          yamlls.enable = true; # YAML
          terraformls.enable = true; # Terraform
          marksman.enable = true; # Markdown
          bashls.enable = true; # Bash / Shell scripts
          jsonls.enable = true; # JSON
        };
      };

      # ── Tree-sitter ────────────────────────────────────────────────────────
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };

      # ── Completion ─────────────────────────────────────────────────────────
      # Replaces YouCompleteMe completion
      blink-cmp.enable = true;

      # ── Format on save ─────────────────────────────────────────────────────
      # Replaces tide fmt-on-save + go-format-before-save
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            python = [ "black" ];
            javascript = [ "prettier" ];
            typescript = [ "prettier" ];
            javascriptreact = [ "prettier" ];
            typescriptreact = [ "prettier" ];
            json = [ "prettier" ];
            yaml = [ "prettier" ];
            markdown = [ "prettier" ];
            nix = [ "nixfmt" ];
            sh = [ "shfmt" ];
            bash = [ "shfmt" ];
          };
          format_on_save = {
            lsp_format = "fallback"; # replaces deprecated lsp_fallback
            timeout_ms = 500;
          };
        };
      };

      # ── Linting ────────────────────────────────────────────────────────────
      # Replaces syntastic
      lint = {
        enable = true;
        lintersByFt = {
          python = [ "ruff" ];
          javascript = [ "eslint" ];
          typescript = [ "eslint" ];
        };
      };

      # ── Git ────────────────────────────────────────────────────────────────
      # gitsigns: replaces git-gutter+ (diff signs in gutter)
      gitsigns.enable = true;
      # neogit: replaces Magit (Spacemacs git layer)
      neogit.enable = true;
      # diffview: full-screen diff and merge tool
      diffview.enable = true;

      # ── Testing ────────────────────────────────────────────────────────────
      # Replaces python-test-runner 'pytest + vim-rspec
      neotest = {
        enable = true;
        adapters.python.enable = true;
        adapters.jest.enable = true;
      };

      # ── Statusline ─────────────────────────────────────────────────────────
      # Replaces vim-airline + spaceline
      lualine.enable = true;

      # ── Terminal ───────────────────────────────────────────────────────────
      # Replaces Spacemacs shell layer (multi-term)
      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          open_mapping = "[[<C-t>]]";
        };
      };

      # ── Indent guides ──────────────────────────────────────────────────────
      # Replaces vim-indent-guides
      indent-blankline.enable = true;

      # ── Diagnostics list ───────────────────────────────────────────────────
      # Replaces location list / syntastic error panel
      trouble.enable = true;

      # ── Auto-pairs ─────────────────────────────────────────────────────────
      # Replaces smartparens
      mini = {
        enable = true;
        modules.pairs = { };
        modules.icons = { }; # modern replacement for nvim-web-devicons
        mockDevIcons = true; # makes plugins expecting web-devicons use mini.icons instead
      };

      # ── TODO highlighting ──────────────────────────────────────────────────
      todo-comments.enable = true;
    };

    # ── Keymaps ──────────────────────────────────────────────────────────────
    keymaps = [
      # File tree (NERDTree muscle memory preserved)
      {
        key = "<C-n>";
        action = ":Neotree toggle<CR>";
        options.desc = "Toggle file tree";
      }
      {
        key = "<leader>e";
        action = ":Neotree toggle<CR>";
        options.desc = "Toggle file tree";
      }
      {
        key = "<leader>r";
        action = ":Neotree reveal<CR>";
        options.desc = "Reveal file in tree";
      }

      # Telescope / file navigation (Spacemacs SPC f)
      {
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<cr>";
        options.desc = "Find files";
      }
      {
        key = "<leader>fr";
        action = "<cmd>Telescope oldfiles<cr>";
        options.desc = "Recent files";
      }
      {
        key = "<leader>/";
        action = "<cmd>Telescope live_grep<cr>";
        options.desc = "Live grep";
      }
      {
        key = "<leader>bb";
        action = "<cmd>Telescope buffers<cr>";
        options.desc = "Switch buffer";
      }
      {
        key = "<leader>bd";
        action = "<cmd>bdelete<cr>";
        options.desc = "Delete buffer";
      }

      # Git (Spacemacs SPC g)
      {
        key = "<leader>gg";
        action = "<cmd>Neogit<cr>";
        options.desc = "Git status (neogit)";
      }
      {
        key = "<leader>gb";
        action = "<cmd>lua require('gitsigns').blame_line()<cr>";
        options.desc = "Git blame line";
      }
      {
        key = "<leader>gd";
        action = "<cmd>DiffviewOpen<cr>";
        options.desc = "Git diff";
      }

      # LSP / Code (Spacemacs SPC c / SPC l)
      {
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
        options.desc = "Code actions";
      }
      {
        key = "<leader>cr";
        action = "<cmd>lua vim.lsp.buf.rename()<cr>";
        options.desc = "Rename symbol";
      }
      {
        key = "<leader>cd";
        action = "<cmd>lua vim.lsp.buf.definition()<cr>";
        options.desc = "Go to definition";
      }
      {
        key = "<leader>cf";
        action = "<cmd>lua require('conform').format()<cr>";
        options.desc = "Format buffer";
      }
      {
        key = "gd";
        action = "<cmd>lua vim.lsp.buf.definition()<cr>";
        options.desc = "Go to definition";
      }
      {
        key = "gr";
        action = "<cmd>lua vim.lsp.buf.references()<cr>";
        options.desc = "References";
      }
      {
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<cr>";
        options.desc = "Hover docs";
      }

      # Terminal (Spacemacs SPC t)
      {
        key = "<leader>tt";
        action = "<cmd>ToggleTerm<cr>";
        options.desc = "Toggle terminal";
      }

      # Tests (Spacemacs SPC x)
      {
        key = "<leader>xt";
        action = "<cmd>lua require('neotest').run.run()<cr>";
        options.desc = "Run nearest test";
      }
      {
        key = "<leader>xT";
        action = "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>";
        options.desc = "Run test file";
      }
      {
        key = "<leader>xs";
        action = "<cmd>lua require('neotest').summary.toggle()<cr>";
        options.desc = "Test summary";
      }

      # Diagnostics
      {
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options.desc = "Toggle diagnostics";
      }
    ];

    # ── Autocommands ─────────────────────────────────────────────────────────
    autoCmd = [
      # Strip trailing whitespace on save (from vimrc: let strip_whitespace_on_save = 1)
      {
        event = "BufWritePre";
        pattern = "*";
        command = "%s/\\s\\+$//e";
      }
    ];
  };
}
