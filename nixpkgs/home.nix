{ Config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "ronan";
  home.homeDirectory = "/Users/ronan";

  
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
  home.packages = with pkgs; [
      # networking utilities
      # sshfs
      # traceroute
      #sshpass
      #wget
      #dnsutils
      #mtr
      
      # language-servers
      nodePackages.pyright
      gopls
      rnix-lsp
      # sumneko-lua-language-server

      # prog langs
      # go
      # gcc
      #clang-tools
      #python3
      #python2

      # golang
      gofumpt
      gotools

       # tools
       # mosh
      openssl
      lsof
      # iotop
      htop
      bat
      #colordiff
      #bandwhich
      #htop
      ripgrep
      stow
      #lf
      highlight
      #broot
      kitty
      # eternal-terminal

      # file management
      trash-cli # recover delete items :)
      fd # rust powered file finder
      fzf # fuzzy finder we all know
      fzy # fuzzy finder which is debatedly better
      nnn # powerful file manager
      lf
      pistol

      # json processing
      jq
      fx

      # source management
      tig

      # utilities
      _1password # password management
      gcalcli

      tmux
      tmuxinator

      # debug adapters
      python3Packages.debugpy
    ];



      nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

    programs.neovim = {
      enable = true;
       vimAlias = true;
       extraConfig = builtins.readFile ~/dotfiles/nvim/config.vim;
       plugins = with pkgs.vimPlugins; [

         # appearence
          gruvbox-community   # colorscheme 
          sonokai
          galaxyline-nvim     # add a nice status bar
          nvim-web-devicons   # add some nice icons, makes things a bit prettier
          vim-startify        # nice startup screen with MRU files
          vim-lastplace       # open file on last place the cursor was
          vim-signature
          scrollbar-nvim
          hiPairs
          Shade-nvim

         # source control
          gitsigns-nvim # add source control symbols to the gutter and enable hunk jumping
          vim-fugitive
          git-messenger-vim
          committia-vim
          vim-twiggy
          vista-vim

         # text formatting
          comment-nvim
          # nvim-ts-context-commentstring
          vim-exchange        # swap text objects
          vim-sandwich        # add/chanfe/remove {[("' around text objects
          vim-matchup         # matchit++ 
          vim-sleuth          # automatically figure out indentation from similar files
          sideways-vim        # easy weapping of params/items in lists
          vim-after-object    # Defines text objects to target text after the designated characters.
          nvim-autopairs

         # vim-endwise         # ends certain structures automatically (if,functions etc) */

         # prog langs
          vim-go              # official go program 
          vim-nix

         # utilities
          which-key-nvim 
          fzf-vim             # fzf functionality in vim 
          vim-smoothie        # smooth scrolling 
          vim-unimpaired      # nicer mapping 
          undotree            # saves undo history, TODO: look into yank history outside of 1-9 
          bclose-vim          # close buffers in a smart way, TODO: maybe look into buffer searcher 
          vim-peekaboo
          vimspector
          # devdocs-vim
          vim-tmux-navigator
          barbar-nvim

          vim-repeat
          vim-eunuch
         # LanguageTool-nvim

         # telescope plins
          telescope-nvim
          popup-nvim
          plenary-nvim

         # treesitter plugins
          # nvim-treesitter
          # nvim-ts-rainbow
          # nvim-treesitter-refactor
          # nvim-treesitter-textobjects

         # LSP plugins
          nvim-lspconfig
          # nvim-lsp-installer
          lspsaga-nvim
          lsp_signature-nvim

         # completion plugins
          nvim-cmp
          cmp-buffer
          cmp-path
          cmp-cmdline
          cmp_luasnip
          cmp-nvim-lsp
          cmp-nvim-lua

          # snippets
          luasnip
          friendly-snippets

          # debugging plugins
          nvim-dap
          nvim-dap-virtual-text
          nvim-dap-ui
          telescope-dap-nvim
          vim-test

          vimux
          nvim-tree-lua
        # TODO: maybe look into a mark plugin, vim-peekaboo or something alike.
       ];
    };
     
     programs.tmux = {
       enable = true;
       keyMode = "vi";
       extraConfig = builtins.readFile ~/dotfiles/tmux/.tmux.conf;
       plugins = with pkgs.tmuxPlugins; [
         sensible # sane tmux defaults
         sessionist # makes sessions management that bit easier
         pain-control # edit tmux panes with ease
         vim-tmux-navigator # naviagate into vim panes with ease 
         resurrect # resume tmux session when system restarts
         continuum # routinely saves the tmux state
         copycat # nifty predefined searches
         tmux-fzf
         # logging
         # tmuxinator
       ];
     };

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      autocd = true; # automatically cd into directory if typed directly into shell
      defaultKeymap = "viins";
      dotDir = "dotfiles/zsh";
      plugins = with pkgs; [
      {
        name = "powerlevel10k";
        src = fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "b7d90c84671183797bdec17035fc2d36b5d12292";
          sha256 = "0nzvshv3g559mqrlf4906c9iw4jw8j83dxjax275b2wi8ix0wgmj";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.6.0";
          sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
        };
        file = "zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-autopair";
        src = fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
        file = "autopair.zsh";
      }
    ];
      prezto = {
	enable = true;
	caseSensitive = false;
        prompt = {
          theme = "powerlevel10k";
        };
        tmux = {
          autoStartRemote = true;
          autoStartLocal = true;
        };
     };
     initExtra = ''
       if [ -e /Users/ronan/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/ronan/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer 
       POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
       export EDITOR=nvim
     '';
    };
   
   programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      delta = { enable = true; };
    };

    programs.command-not-found = {
      enable = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      changeDirWidgetCommand = "fd --type d";
    };

    programs.kitty = {
      enable = true;
    };
  }


