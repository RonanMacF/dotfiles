{ config, pkgs, lib, inputs, ... }:

let
  username = "ronan";
  homePrefix = if pkgs.stdenv.isDarwin then "/Users" else "/home";
in
{
  imports = [
    ./modules/shell.nix
    ./modules/tmux.nix
    ./modules/git.nix
    ./modules/terminal.nix
  ];

  home.username = username;
  home.homeDirectory = "${homePrefix}/${username}";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.npm-global/bin"
  ];

  home.sessionVariables = {
    PAGER = "less";
    LESS = "-R --mouse --wheel-lines=3";
    MANPAGER = "nvim +Man!";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    PIP_REQUIRE_VIRTUALENV = "1";
    COLORTERM = "truecolor";
    BAO_ADDR = "https://bao.sw.internal.nexthop.ai:8200";
  };

  home.packages = with pkgs; [
    # fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only

    # languages
    go
    python3
    nodejs

    # language servers
    gopls
    basedpyright
    lua-language-server
    bash-language-server
    taplo
    vscode-langservers-extracted

    # go tools
    gofumpt
    (lib.lowPrio gotools)
    golines
    golangci-lint
    gotestsum
    delve
    gomodifytags
    impl
    gotests
    govulncheck

    # python tools
    uv

    # formatters / linters
    ruff
    stylua
    shellcheck
    shfmt
    markdownlint-cli2
    prettier
    ast-grep
    tree-sitter

    # debug adapters
    python3Packages.debugpy

    # build tools
    bazelisk
    gcc
    luarocks
    openssl

    # git tools
    git-absorb
    difftastic

    # cli tools
    curl
    ripgrep
    fd
    eza
    jq
    yq-go
    ssm-session-manager-plugin
    fx
    btop
    lsof
    trash-cli
    tealdeer
    sshfs
    sesh
    mosh

    # utilities
    jira-cli-go
    _1password-cli
    gcalcli
    postgresql_14
    grafana-loki  # provides logcli
    awscli2
    openbao  # provides bao
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    libnotify  # provides notify-send for zsh-auto-notify
  ]
  ;

  home.file.".config/.jira/.config.yml".source = ./config/jira/config.yml;

  # acli config — auth via ATLASSIAN_* env vars, no config file needed

  # Install npm-based CLI tools not in nixpkgs
  home.activation.installNpmTools = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    mkdir -p "$NPM_CONFIG_PREFIX"
    for bin_pkg in claude:@anthropic-ai/claude-code auggie:@augmentcode/auggie markdown-toc:markdown-toc; do
      bin="''${bin_pkg%%:*}"
      pkg="''${bin_pkg#*:}"
      if ! "$NPM_CONFIG_PREFIX/bin/$bin" --version >/dev/null 2>&1; then
        ${pkgs.nodejs}/bin/npm install -g "$pkg" 2>/dev/null || true
      fi
    done
  '';
}
