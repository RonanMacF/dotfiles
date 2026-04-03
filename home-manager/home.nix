{ config, pkgs, inputs, ... }:

let
  username = "ronan";
  homePrefix = if pkgs.stdenv.isDarwin then "/Users" else "/home";
in
{
  home.username = username;
  home.homeDirectory = "${homePrefix}/${username}";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    MANPAGER = "nvim +Man!";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    PIP_REQUIRE_VIRTUALENV = "1";
  };

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    curl
    nodejs
    sshfs

    # language servers
    gopls
    basedpyright
    lua-language-server
    bash-language-server
    taplo
    vscode-langservers-extracted

    # languages
    go
    python3

    # formatters / linters
    gofumpt
    gotools
    golines
    golangci-lint
    gotestsum
    delve
    ruff
    stylua
    shellcheck
    shfmt
    markdownlint-cli2
    tree-sitter

    # tools
    gcc
    lazygit
    luarocks
    openssl
    lsof
    htop
    bat
    ripgrep
    highlight
    stow

    # file management
    trash-cli
    fd
    fzf

    # reference
    tealdeer

    # json processing
    jq
    fx

    # source management
    tig

    # utilities
    _1password-cli
    gcalcli
    eza
    maccy

    # debug adapters
    python3Packages.debugpy
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    # Plugins managed by LazyVim in ~/.config/nvim/
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig = ''
      # Allow OSC escape sequences to pass through to the outer terminal (kitty).
      # Required for notifications and image display over SSH+tmux.
      set -g allow-passthrough on

      ${builtins.readFile "${config.home.homeDirectory}/dotfiles/tmux/tmux.conf"}
    '';
    plugins = with pkgs.tmuxPlugins; [
      sensible
      sessionist
      pain-control
      vim-tmux-navigator
      resurrect
      continuum
      copycat
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
    ];
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    defaultKeymap = "viins";
    dotDir = "${config.home.homeDirectory}/dotfiles/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # Manual compinit in initContent so fzf-tab sources after it.
    enableCompletion = false;
    shellAliases = {
      ll = "eza --long --all --group --icons --time-style=long-iso";
      hms = "home-manager switch --flake ~/.config/home-manager --impure";
      ssh = "kitten ssh";
      hg = "kitten hyperlinked-grep";
    };
    envExtra = "";
    history = {
      append = true;
      findNoDups = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      saveNoDups = true;
    };
    zsh-abbr = {
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
    plugins = [
      {
        name = "zsh-you-should-use";
        src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
      }
      {
        name = "auto-notify";
        src = inputs.zsh-auto-notify;
      }
      {
        name = "zsh-completions";
        src = "${pkgs.zsh-completions}/share/zsh/site-functions";
      }
      {
        name = "git-extra-commands";
        src = inputs.git-extra-commands;
        file = "git-extra-commands.zsh";
      }
    ];
    initContent = ''
      # Override auto-notify to use kitty's OSC 99 desktop notification protocol.
      # Works over SSH -- the escape sequence travels through the tunnel to
      # your local kitty, which renders it as a native macOS notification.
      # Also works inside tmux with allow-passthrough enabled.
      _auto_notify_message() {
        local command="$1"
        local elapsed="$2"
        local exit_code="$3"

        local title body
        if [[ "$exit_code" == "0" ]]; then
          title="Command completed ($elapsed s)"
          body="$command"
        else
          title="Command failed (exit $exit_code, $elapsed s)"
          body="$command"
        fi

        if [[ -n "$TMUX" ]]; then
          printf '\ePtmux;\e\e]99;i=auto-notify:d=0;%s\a\e\e]99;i=auto-notify:d=1:p=body;%s\a\e\\' "$title" "$body"
        else
          printf '\e]99;i=auto-notify:d=0;%s\e\\\e]99;i=auto-notify:d=1:p=body;%s\e\\' "$title" "$body"
        fi
      }

      # Plugin skips enable_auto_notify on Linux without notify-send.
      # We override _auto_notify_message with OSC 99, so force-enable it.
      enable_auto_notify

      # https://discourse.nixos.org/t/darwin-home-manager-zsh-fzf-and-zsh-fzf-tab/33943
      zvm_after_init_commands+=(eval "$(fzf --zsh)")

      # Completion: zstyles before compinit, fzf-tab after
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

      autoload -U compinit && compinit -C
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    '';
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      column.ui = "auto";
      branch.sort = "-committerdate";
      status.submoduleSummary = true;
      submodule.recurse = true;
      tag.sort = "version:refname";
      init.defaultBranch = "main";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
        submodule = "log";
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      help.autocorrect = "prompt";
      commit.verbose = true;
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

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$golang$python$nix_shell$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };
      directory = {
        truncation_length = 3;
        truncation_symbol = ".../";
      };
      git_branch.format = "[$branch]($style) ";
      git_status.format = "[$all_status$ahead_behind]($style) ";
      golang.format = "[$symbol$version]($style) ";
      python.format = "[$symbol$version( \\($virtualenv\\))]($style) ";
      nix_shell.format = "[$symbol$state]($style) ";
      cmd_duration = {
        min_time = 3000;
        format = "[$duration]($style) ";
      };
    };
  };

  programs.fzf = {
    enable = true;
    changeDirWidgetCommand = "fd --type d";
    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    extraConfig = builtins.readFile "${config.home.homeDirectory}/dotfiles/kitty/kitty.conf";
  };

  # Fix Kitty macOS notifications: Nix's binary wrapper exec's .kitty-wrapped
  # from the Nix store, which breaks the /Applications/kitty.app bundle context
  # that macOS needs for UNUserNotificationCenter. This activation script
  # replaces the wrapper so the process runs from the local app bundle.
  home.activation.fixKittyNotifications = if pkgs.stdenv.isDarwin then
    config.lib.dag.entryAfter [ "writeBoundary" "copyApplications" ] (let
    wrapperC = pkgs.writeText "kitty-wrapper.c" ''
      #include <unistd.h>
      #include <stdlib.h>
      #include <stdio.h>
      #include <string.h>
      /* NIX_PATH and WRAPPED are injected at compile time via -D flags */
      int main(int argc, char *argv[]) {
          const char *cur = getenv("PATH");
          char buf[8192];
          if (cur) snprintf(buf, sizeof buf, "%s:%s", NIX_PATH, cur);
          else snprintf(buf, sizeof buf, "%s", NIX_PATH);
          setenv("PATH", buf, 1);
          argv[0] = WRAPPED;
          execv(argv[0], argv);
          perror("kitty wrapper execv");
          return 1;
      }
    '';
    entitlementsPlist = pkgs.writeText "kitty-entitlements.plist" ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>com.apple.security.cs.disable-library-validation</key>
          <true/>
          <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
          <true/>
      </dict>
      </plist>
    '';
  in ''
    KITTY_APP="/Applications/kitty.app"
    MACOS_DIR="$KITTY_APP/Contents/MacOS"

    if [ -d "$KITTY_APP" ] && [ -f "$MACOS_DIR/kitty" ]; then
      NIX_KITTY_WRAPPED=$(${pkgs.binutils-unwrapped}/bin/strings "$MACOS_DIR/kitty" | grep '/nix/store.*/.kitty-wrapped$' | head -1 || true)

      if [ -n "$NIX_KITTY_WRAPPED" ] && [ -f "$NIX_KITTY_WRAPPED" ]; then
        NIX_PATH=$(${pkgs.binutils-unwrapped}/bin/strings "$MACOS_DIR/kitty" | grep '^/nix/store.*bin$' | head -1)

        cp "$NIX_KITTY_WRAPPED" "$MACOS_DIR/.kitty-wrapped"

        cc -DNIX_PATH="\"$NIX_PATH\"" \
           -DWRAPPED="\"$MACOS_DIR/.kitty-wrapped\"" \
           -o "$MACOS_DIR/kitty" ${wrapperC} 2>/dev/null
        codesign --force --sign - "$MACOS_DIR/kitty" 2>/dev/null

        codesign --force --sign - \
          --identifier "net.kovidgoyal.kitty" \
          --options runtime \
          --entitlements ${entitlementsPlist} \
          "$MACOS_DIR/.kitty-wrapped" 2>/dev/null
      fi
    fi
  '')
  else
    config.lib.dag.entryAfter [ "writeBoundary" ] "";

  # Ensure Kitty is registered in macOS notification preferences.
  # Without this entry, macOS 26+ defaults to "denied" for unknown apps
  # and never shows a permission prompt.
  home.activation.registerKittyNotifications = config.lib.dag.entryAfter [ "fixKittyNotifications" ] ''
    if [ "$(uname)" = "Darwin" ]; then
      ${pkgs.python3}/bin/python3 - << 'PYEOF'
import plistlib, os, sys
path = os.path.expanduser("~/Library/Preferences/com.apple.ncprefs.plist")
if not os.path.exists(path):
    sys.exit(0)
with open(path, "rb") as f:
    d = plistlib.load(f)
apps = d.get("apps", [])
for app in apps:
    if app.get("bundle-id") == "net.kovidgoyal.kitty":
        sys.exit(0)  # already registered
apps.append({
    "bundle-id": "net.kovidgoyal.kitty",
    "flags": 41951246,
    "path": "/Applications/kitty.app",
    "content_visibility": 0,
    "grouping": 0,
    "src": 0,
})
d["apps"] = apps
with open(path, "wb") as f:
    plistlib.dump(d, f)
PYEOF
    fi
  '';

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
