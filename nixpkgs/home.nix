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
  home.stateVersion = "20.09";

  manual.manpages.enable = false;
  #home.file."${config.xdg.configHome}/nvim/parser/c.so".source = "${pkgs.tree-sitter.builtGrammars.c}/parser";
  
  home.packages = with pkgs; [
      # networking utilities
      # sshfs
      # traceroute
      #sshpass
      #wget
      #dnsutils
      #mtr
      
      # prog langs
      go
      gopls
      gcc
      #clang-tools
      #python3
      #python2
      # python-language-server

      # tools
      # mosh
      #openssl
      #lsof
      #jq
      ## iotop
      #htop
      git
      bat
      #colordiff
      #bandwhich
      #htop
      fzf
      ripgrep
      stow
      #lf
      #pistol
      highlight
      #broot
      #fd
      #tig
      kitty
    ];

    programs.neovim = {
      enable = true;
      vimAlias = true;
      package = pkgs.neovim-nightly;
      extraConfig = builtins.readFile ~/dotfiles/nvim/init.vim;
      plugins = with pkgs.vimPlugins; [

        # appearence
        gruvbox-community   # colorscheme 
        indentLine          # display line indentation markers 
        rainbow             # highlight matching parentheses in different colors 
        vim-airline         # add a nice status bar
        vim-devicons        # add some nice icons, makes things a bit prettier
        vim-startify        # nice startup screen with MRU files
        vim-lastplace       # open file on last place the cursor was
        vim-signature

        # source control
        vim-signify         # add source control symbols to the gutter and enable hunk jumping
        vim-fugitive
        git-messenger-vim
        committia-vim
        vim-twiggy

        # coc plugins
        coc-nvim
        coc-yank
        coc-python
        coc-yaml
        coc-json
        coc-pairs
        # coc-go
        coc-fzf
        coc-highlight
        vista-vim

        # text formatting
        vim-commentary      # easilt do comments
        vim-exchange        # swap text objects
        vim-sandwich        # add/chanfe/remove {[("' around text objects
        vim-matchup         # matchit++ 
        vim-sleuth          # automatically figure out indentation from similar files
        sideways-vim        # easy weapping of params/items in lists
        vim-after-object    # Defines text objects to target text after the designated characters.

        # vim-endwise         # ends certain structures automatically (if,functions etc) */

        # prog langs
        vim-go              # official go program 
        # semshi              # python sybtax highlighter 
        vim-nix

        # vim-polyglot      # syntac highlighing language pack

        # utilities
        fzf-vim             # fzf functionality in vim 
        vim-smoothie        # smooth scrolling 
        vim-unimpaired      # nicer mapping 
        undotree            # saves undo history, TODO: look into yank history outside of 1-9 
        bclose-vim          # close buffers in a smart way, TODO: maybe look into buffer searcher 
        vim-peekaboo
        vimspector
        # devdocs-vim
        vim-sneak
        vim-tmux-navigator

        vim-repeat
        vim-eunuch

        # TODO: maybe look into a mark plugin, vim-peekaboo or something alike.
      ];
    };

    programs.tmux = {
      enable = true;
      historyLimit = 10000;
      keyMode = "vi";
      terminal = "screen-256color";
      extraConfig = builtins.readFile ~/dotfiles/tmux/.tmux.conf;
      plugins = with pkgs.tmuxPlugins; [
        resurrect
        continuum
        vim-tmux-navigator
        logging
        prefix-highlight
      ];
    };
  }
