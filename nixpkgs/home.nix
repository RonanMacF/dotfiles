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

    home.packages = [
    pkgs.htop
    pkgs.fortune
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = builtins.readFile ~/dotfiles/nvim/init.vim;
    plugins = with pkgs.vimPlugins; [
      vim-polyglot
      gruvbox
      coc-nvim
      coc-yank
      coc-python
      coc-yaml
      coc-json
      vim-signify
      vim-startify
    ];
  };
}
