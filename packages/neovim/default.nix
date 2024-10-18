{ pkgs }:
let 
  extraPackages = with pkgs; [
    ripgrep clojure-lsp terraform-lsp nodejs nil
  ];
  jsSnippetsContent = builtins.readFile ./config/javascript.snippets;
  jsSnippetsHash = builtins.hashFile "md5" ./config/javascript.snippets;
  jsSnippetsFile = pkgs.writeText "javascript-${jsSnippetsHash}.snippets" jsSnippetsContent;
  snippetsDir = ./config;
  cocSettingsJson = pkgs.writeText "coc-settings.json" (builtins.toJSON {
    snippets = {
      priority = 1;
      userSnippetsDirectory = "${snippetsDir}";
      extends = {
        typescript = [ "javascript" ];
      };
      ultisnips = {
        enable = true;
      };
      snipmate = {
        enable = false;
      };
    };
    languageserver = {
      "clojure-lsp" = {
        command = "clojure-lsp";
        filetypes = [ "clojure" ];
        rootPatterns = [ "project.clj" ];
        additionalSchemes = [ "jar" "zipfile" ];
      };
      terraform = {
        command = "terraform-lsp";
        filetypes = [ "terraform" "tf" ];
        initializationOptions = {};
        settings = {};
      };
      tsserver = {
        filetypes = [ "ts" "tsx" ];
      };
      nix = {
        command = "nil";
        filetypes = [ "nix" ];
        rootPatterns = [ "flake.nix" ];
      };
    };

    tsserver = {
      useLocalTsdk = true;
      log = "verbose";
      enableTracing = true;
      trace = {
        server = "verbose";
      };
      maxTsServerMemory = 8192;
    };

    list = {
      source = {
        symbols = {
          excludes = [ "**/node_modules/**/*" ];
        };
      };
    };

    typescript = {
      format = {
        insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = true;
      };
    };

    suggest = {
      completionItemKindLabels = {
        method = "  ";
        function = "  ";
        variable = "[]";
        field = "  ";
        typeParameter = "<>";
        constant = "  ";
        class = " פּ ";
        interface = " 蘒";
        struct = "  ";
        event = "  ";
        operator = "  ";
        module = "  ";
        property = "  ";
        enum = " 練";
        reference = "  ";
        keyword = "  ";
        file = "  ";
        folder = " ﱮ ";
        color = "  ";
        unit = " 塞 ";
        snippet = "  ";
        text = "  ";
        constructor = "  ";
        value = "  ";
        enumMember = "  ";
      };
    };
  });


  nvimConfigDir = pkgs.symlinkJoin {
    name = "nvim-config";
    paths = [
      (pkgs.writeTextDir "coc-settings.json" (builtins.readFile cocSettingsJson))
      (pkgs.writeTextDir "clojure.snippets" (builtins.readFile ./config/clojure.snippets))
      (pkgs.writeTextDir "javascript.snippets" (builtins.readFile jsSnippetsFile))
      (pkgs.writeTextDir "cheatsheet.txt" (builtins.readFile ./config/cheatsheet.txt))
    ];
  };
  customNeovim = (pkgs.neovim.override {
    configure = {
      customRC = ''
        ${builtins.readFile ./config/vimrc}
        let g:coc_config_home = '${nvimConfigDir}'
        let &runtimepath .= ',${nvimConfigDir}'
      '';
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [ vim-nix hop-nvim fzf-vim vim-pencil goyo vim-markdown vimwiki vim-gnupg conjure coc-nvim vim-airline vim-fugitive vim-sexp 
          vim-clojure-static vim-visual-multi vim-floaterm
          vim-jsx-pretty coc-snippets vim-gitgutter nerdtree lazygit-nvim vim-code-dark coc-clap coc-tsserver coc-go coc-pyright coc-rust-analyzer coc-clangd
          vim-devicons bufferline-nvim vim-jsdoc vim-clap coc-flutter vim-surround vim-commentary vim-terraform
          telescope-nvim cheatsheet-nvim nvim-treesitter-context
          (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
          (pkgs.vimUtils.buildVimPlugin {
            name = "portkey";
            src = pkgs.fetchFromGitHub {
              repo = "portkey";
              owner = "dsawardekar";
              rev = "2afd378b3fdec04138e9bda17840c60d0d9cca7d";
              sha256 = "02ga889h16kfz5cmbxy1hj788zdf7sk03h8x1xzlpdnp23jhbcf0";
            };
          })
          (pkgs.vimUtils.buildVimPlugin {
            name = "vim-ember-hbs";
            src = pkgs.fetchFromGitHub {
              repo = "vim-ember-hbs";
              owner = "joukevandermaas";
              rev = "c47e1958a6c190c9d79ac66cb812f1a1d3b4e968";
              sha256 = "0asxn18j65fihzwdpjbpcnqr6klwk5dr5v9lzw9imjj50ia40ah3";
            };
          })
          plenary-nvim nui-nvim (pkgs.vimUtils.buildVimPlugin {
            name = "nvim-magic";
            src = pkgs.fetchFromGitHub {
              repo = "nvim-magic";
              owner = "jameshiew";
              rev = "778ad035534278e5b3b5e31983af7d1e04f557a0";
              sha256 = "sha256-ZLHs9/ArppvJ6EYra6m4X75cr7pw/dr8HalxWdQL67w=";
            };
          })
          (pkgs.vimUtils.buildVimPlugin {
            name = "codecompanion";
            src = pkgs.fetchFromGitHub {
              repo = "codecompanion.nvim";
              owner = "olimorris";
              rev = "fc146070cc341b1503d61daf6746edb4d0d7e6aa";
              sha256 = "sha256-UiB05lSjiKWq3eGQln9zMkNVzf3n1r7U3H1sVlrcz7k=";
            };
          })
             ];
        };
      };
    });
  neovimWrapped = pkgs.symlinkJoin {
    name = "neovim";
    paths = [ customNeovim ] ++ extraPackages;
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix PATH : ${pkgs.lib.makeBinPath extraPackages}
    '';
  };
in
pkgs.writeShellScriptBin "nvim" ''
  exec ${neovimWrapped}/bin/nvim "$@"
''
