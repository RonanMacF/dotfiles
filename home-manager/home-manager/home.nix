{ config, pkgs, ... }:

{
  home.username = "ronan";
  home.homeDirectory = "/Users/ronan";
  home.stateVersion = "25.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
# npm config set prefix "${HOME}/.cache/npm/global" 


  home.packages = with pkgs; [
      nerd-fonts.fira-code

      curl
      nodejs
      # networking utilities
      sshfs
      # traceroute
      #sshpass
      #wget
      #dnsutils
      #mtr
      
      # language-servers
      gopls
      go
      # sumneko-lua-language-server

      gitstatus
      # prog langs
      # go
      # gcc
      #clang-tools
      python3

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
      # eternal-terminal
      luarocks

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
      _1password-cli # password management
      gcalcli

      # debug adapters
      python3Packages.debugpy
      zoxide

    eza
    ];

    programs.neovim = {
      enable = true;
       vimAlias = true;
       #extraConfig = builtins.readFile ~/dotfiles/nvim/config.vim;
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
       extraConfig = builtins.readFile ~/dotfiles/tmux/tmux.conf;
       plugins = with pkgs.tmuxPlugins; [
         sensible # sane tmux defaults
         sessionist # makes sessions management that bit easier
         pain-control # edit tmux panes with ease
         vim-tmux-navigator # naviagate into vim panes with ease 
         resurrect # resume tmux session when system restarts
         continuum # routinely saves the tmux state
         copycat # nifty predefined searches
         tmux-fzf
	  {
              plugin = catppuccin;
              extraConfig = ''
                set -g @catppuccin_flavor 'mocha'
                set -g @catppuccin_window_status_style 'rounded'
                set -g status-right-length 100
                set -g status-left-length 100
                set -g status-left ""
                set -g status-right "#{E:@catppuccin_status_application}"
                set -ag status-right "#{E:@catppuccin_status_session}"
                set -ag status-right "#{E:@catppuccin_status_uptime}"
              '';
            }
         # logging
         # tmuxinator
       ];
     };

    programs.zsh = {
      enable = true;
      autocd = true; # automatically cd into directory if typed directly into shell
      defaultKeymap = "viins";
      dotDir = "${config.home.homeDirectory}/dotfiles/zsh";
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = false;
      shellAliases = {
          ll = "exa --long --all --group --icons --time-style=long-iso";
        };
      envExtra = "EDITOR=nvim\nVISUAL=nvim\nPOWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true";
      history = {
        append = true;
        findNoDups = true;
        expireDuplicatesFirst = true;
        ignoreDups = true;
        saveNoDups = true;
      };
      zsh-abbr ={
         enable = true;
         abbreviations = {
  gco = "git checkout";
  l = "less";
          };

        globalAbbreviations = {
  G = "| grep";
  L = "| less -R";
};
        };
        
      plugins = with pkgs; [
	    {
	      name = "powerlevel10k";
	      src = fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "36f3045d69d1ba402db09d09eb12b42eebe0fa3b";
          sha256 = "BRJyGn+gTGUWifpJ1ziBKVHACcWw+R5N/HdUi8HzSvY=";
        };
        file = "powerlevel10k.zsh-theme";
	    }
	    {
	      name = "zsh-you-should-use";
	     src = fetchFromGitHub {
		owner = "MichaelAquilina";
		repo = "zsh-you-should-use";
		rev = "56616de037082f7dc0a143eb244ea27e5a697ef9";
		sha256 = "XbTZpyUIpALsVezqnIfz7sV26hMi8z+2dW0mL2QbVIE=";
	      };
	    }
	    {
	      name = "auto-notify";
	      src = fetchFromGitHub {
		owner = "MichaelAquilina";
		repo = "zsh-auto-notify";
		rev = "27c07dddb42f05b199319a9b66473c8de7935856";
		sha256 = "ScBwky33leI8mFMpAz3Ng2Z0Gbou4EWMOAhkcMZAWIc=";
	      };
	    }
      {
          name = "zsh-completions";
          	      src = fetchFromGitHub {
		owner = "zsh-users";
		repo = "zsh-completions";
		rev = "7fbdd25526afeefb0fc139fc012831211ed718bf";
		sha256 = "7A2UnvdBPtmYur4GgUNwxDUFFE4i0TGnJS42H5XoBlM=";
	      };
          completions = ["zsh-completions/src"];


        }
	    #{
	      #name = "vi-mode";
	      #src = pkgs.zsh-vi-mode;
	     # file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
	    #}
     #  {
    #name = "zsh-vi-mode";
    #src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
  #}
	    {
	      name = "git-extra-commands";
	      src = fetchFromGitHub {
		owner = "unixorn";
		repo = "git-extra-commands";
		rev = "c4af0d9fea280863d7bda858ba24e22e025cf0f9";
		sha256 = "hhJQqiHvkq+UjgKAKUnvi9KeyRK1vbX2r8PkcVXJYZU=";
	      };
	      file = "git-extra-commands.zsh";
	    }
        {
    name = "fzf-tab";
   src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
  }
	    ];
     initContent = ''
       source ~/dotfiles/zsh/.p10k.zsh
       # https://discourse.nixos.org/t/darwin-home-manager-zsh-fzf-and-zsh-fzf-tab/33943
       zvm_after_init_commands+=(eval "$(fzf --zsh)")

       # Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

autoload -U compinit && compinit
     '';
    };
   
programs.git = {
  enable = true;
  package = pkgs.gitFull;
  settings = {
# sort branches by last committed
    column = {
      ui = "auto";
    };
    branch.sort = "-committerdate";

    status.submoduleSummary = true; # TODO
    submodule.recurse = true;

# better tag ordering
    tag.sort = "version:refname";

    init.defaultBranch = "main";

    diff = {
      algorithm = "histogram";
      colorMoved = "plain";
      mnemonicPrefix = true;
      renames = true;
      submodule = "log";
    };
    push={
      default = "simple";
      autoSetupRemote = true;
      followTags = true; # also push local tags
    };
    fetch = {
      prune = true;
      pruneTags = true;
      all = true;

    };
    help.autocorrect = "prompt";
    commit.verbose = true; # show diff in commit comments

# remember conflict resolutions and reapply
      rerere = {
        enabled = true;
        autoupdate = true;
      };

    rebase = {
      autoSquash = true;
      autoStash = true;
      updateRefs = true;
    };
  core = {
    fsmonitor = true;
    untrackedCache = true;
  };
  merge.conflictstyle = "zdiff3";
  pull.rebase = true;
  };
};

    programs.delta = {
enable = true;
enableGitIntegration = true;

    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      };

    programs.fzf = {
      enable = true;
      #enableZshIntegration = true;
      changeDirWidgetCommand = "fd --type d";
      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];
    };

    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      shellIntegration.enableZshIntegration = true;
      extraConfig = builtins.readFile "${config.home.homeDirectory}/dotfiles/kitty/kitty.conf";
    };
}
