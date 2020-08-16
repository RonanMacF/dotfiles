{ config, pkgs, ... }:

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

  home.packages = with pkgs; [
      # networking utilities
      # sshfs
      # traceroute
      sshpass
      wget
      dnsutils
      mtr
      
      # prog langs
      go
      gopls
      gcc
      clang-tools
      python3
      python2
      # python-language-server

      # tools
      mosh
      openssl
      lsof
      jq
      # iotop
      htop
      git
      bat
      colordiff
      bandwhich
      htop
      fzf
      ripgrep
      stow
    ];

    programs.neovim = {
      enable = true;
      vimAlias = true;
      extraConfig = builtins.readFile ~/dotfiles/nvim/init.vim;
      plugins = with pkgs.vimPlugins; [
        fzf-vim
        gruvbox-community
        coc-nvim
        coc-yank
        coc-python
        coc-yaml
        coc-json
        coc-pairs
        coc-go
        vim-signify
        vim-startify
        rainbow
        vim-commentary
        vim-go
        vim-polyglot
        indentLine
        vim-repeat
        vim-unimpaired
        vim-eunuch
        vim-exchange
        vim-devicons
        vim-sleuth
        vim-airline
        vim-lastplace
      ];
    };
  }
