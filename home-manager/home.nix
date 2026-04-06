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
    "$HOME/.npm-global/bin"
  ];

  home.sessionVariables = {
    PAGER = "less";
    MANPAGER = "nvim +Man!";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    PIP_REQUIRE_VIRTUALENV = "1";
    COLORTERM = "truecolor";
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
    gotools
    golines
    golangci-lint
    gotestsum
    delve

    # formatters / linters
    ruff
    stylua
    shellcheck
    shfmt
    markdownlint-cli2
    tree-sitter

    # debug adapters
    python3Packages.debugpy

    # build tools
    gcc
    luarocks
    openssl

    # cli tools
    curl
    ripgrep
    fd
    eza
    jq
    fx
    btop
    lsof
    trash-cli
    tealdeer
    sshfs
    sesh
    mosh

    # utilities
    _1password-cli
    gcalcli
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    libnotify  # provides notify-send for zsh-auto-notify
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    maccy
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
    # Plugins managed by LazyVim in ~/.config/nvim/
  };

  programs.tmux = {
    enable = true;
    shortcut = if pkgs.stdenv.isDarwin then "a" else "b";
    shell = "${pkgs.zsh}/bin/zsh";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 100000;
    terminal = "tmux-256color";
    clock24 = false;
    extraConfig = ''
      # Allow OSC escape sequences to pass through to the outer terminal (kitty).
      set -g allow-passthrough on

      # Focus events — needed for Neovim autoread and gitsigns
      set -g focus-events on

      # OSC 52 clipboard — works everywhere (local, SSH, tmux)
      set -g set-clipboard on

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Activity alerts
      setw -g monitor-activity on
      set -g visual-activity on

      # Auto-rename windows to current directory
      set -g automatic-rename on
      set -g automatic-rename-format "#{b:pane_current_path}"

      # Split panes in current directory
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Vi copy-mode with system clipboard
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi V send -X select-line
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # Pane resizing (repeatable)
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Window switching with Alt+number
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Swap windows
      bind -r < swap-window -d -t -1
      bind -r > swap-window -d -t +1

      # Lazygit popup
      bind g display-popup -E -w 90% -h 90% -d "#{pane_current_path}" "lazygit"

      # Quick popup terminal
      bind -n M-t display-popup -E -w 80% -h 80% -d "#{pane_current_path}"

      # Sesh session picker
      bind "T" run-shell "sesh connect \"$(
        sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '  ' \
          --header '  ^a all ^t tmux ^x zoxide ^d kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-x:change-prompt(  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}'
        )\""

      # Toggle last session
      bind L run-shell "sesh last"

      # Stay in tmux when closing a session
      set -g detach-on-destroy off

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

      # Resurrect/continuum
      set -g @resurrect-capture-pane-contents 'on'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '10'
    '';
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      resurrect
      continuum
      tmux-fzf
      tmux-thumbs
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
      ls = "ls --color=auto";
      ll = "eza --long --all --group --icons --time-style=long-iso";
      hms = "home-manager switch --flake ~/.config/home-manager --impure";
      gist = "gh gist create -";
    } // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
      hg = "kitten hyperlinked-grep";
    };
    history = {
      size = 50000;
      save = 50000;
      append = true;
      extended = true;
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
      # Auto-attach to tmux on SSH login
      if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && $- == *i* ]]; then
        tmux new-session -A -s main
      fi

      # Path-aware word deletion (stop at / . - instead of eating entire paths)
      WORDCHARS=''\'''${WORDCHARS//[\/.]}'
      setopt CORRECT INTERACTIVE_COMMENTS NO_BEEP

      # fzf + ripgrep live grep — type query, results update live, Enter opens in nvim
      frg() {
        local initial_query="''${*:-}"
        : | fzf --ansi --disabled --query "$initial_query" \
          --bind "start:reload:rg --column --line-number --no-heading --color=always --smart-case {q} || true" \
          --bind "change:reload:rg --column --line-number --no-heading --color=always --smart-case {q} || true" \
          --delimiter : \
          --preview 'bat --color=always --highlight-line {2} {1}' \
          --preview-window 'right:60%:+{2}+3/3:border-left' \
          --bind 'enter:become(nvim {1} +{2})'
      }

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

      # ── Completion config ──
      # Case-insensitive, then partial-word, then substring
      zstyle ':completion:*' matcher-list \
        'm:{a-zA-Z}={A-Za-z}' \
        'r:|[._-]=* r:|=*' \
        'l:|=* r:|=*'
      zstyle ':completion:*' menu no
      zstyle ':completion:*' group-name ""
      zstyle ':completion:*:descriptions' format '%F{yellow}%B── %d ──%b%f'
      zstyle ':completion:*:warnings' format '%F{red}── no matches ──%f'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' verbose yes
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$HOME/.cache/zsh/compcache"
      zstyle ':completion:*' special-dirs true
      zstyle ':completion:*' squeeze-slashes true
      zstyle ':completion:*:cd:*' ignore-parents parent pwd
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
      zstyle ':completion:*:*:kill:*' menu yes select

      # fzf-tab
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
      zstyle ':fzf-tab:*' switch-group '<' '>'

      autoload -U compinit && compinit -C
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    '';
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user.name = "ronan-nexthop";
      user.email = "ronan@nexthop.ai";
      user.signingkey = "B870F0F4471D8107";
      gpg.program = "${pkgs.gnupg}/bin/gpg2";
      alias = {
        ci = "commit";
        sw = "switch";
        # Checkout remote branch as local tracking branch (shows branch name, not hash)
        cor = "!f() { git switch --track \"$1\" 2>/dev/null || git switch --detach \"$1\"; }; f";
        rst = "restore";
        ds = "diff --staged";
        dw = "diff --word-diff";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        recent = "branch --sort=-committerdate --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:green)%(committerdate:relative)%(color:reset) %(contents:subject)'";
        last = "diff-tree --no-commit-id --name-status -r HEAD";
        amend = "commit --amend --no-edit";
        undo = "reset --soft HEAD~1";
        wip = "!git add -A && git commit -m 'wip: checkpoint'";
        unwip = "!git log -1 --format='%s' | grep -q '^wip:' && git reset HEAD~1";
        fixup = "!f() { git commit --fixup=$1 && GIT_SEQUENCE_EDITOR=: git rebase --autosquash --autostash $1~1; }; f";
        find = "!f() { git log --all -S\"$1\" --oneline; }; f";
        who = "blame -w -C -C -C";
        cleanup = "!git branch --merged main | grep -v '^[ *]*main$' | xargs -r git branch -d";
        pub = "!f() { git push -u origin $(git branch --show-current); }; f";
      };
      column.ui = "auto";
      branch.sort = "-committerdate";
      status.submoduleSummary = true;
      submodule.recurse = true;
      tag.sort = "version:refname";
      init.defaultBranch = "main";
      diff = {
        algorithm = "histogram";
        colorMoved = "dimmed-zebra";
        colorMovedWS = "allow-indentation-change";
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
        writeCommitGraph = true;
      };
      help.autocorrect = "prompt";
      commit.verbose = true;
      commit.gpgSign = true;
      log.date = "iso";
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
      transfer.fsckObjects = true;
      receive.fsckObjects = true;
      merge.conflictstyle = "zdiff3";
      merge.autoStash = true;
      pull.rebase = true;
      init.templateDir = "${config.home.homeDirectory}/.config/git/template";
    };
  };

  # Global git template hooks — applied to new clones/inits, chainable with pre-commit
  home.file.".config/git/template/hooks/prepare-commit-msg" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Add Signed-off-by if not already present
      SOB="Signed-off-by: $(git config user.name) <$(git config user.email)>"
      grep -qs "^$SOB" "$1" || echo "$SOB" >> "$1"
    '';
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      style = "numbers,changes";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
        nerdFontsVersion = "3";
        showRandomTip = false;
        showBottomLine = false;
        border = "rounded";
        theme = {
          lightTheme = false;
          activeBorderColor = [ "#fe8019" "bold" ];
          inactiveBorderColor = [ "#665c54" ];
          searchingActiveBorderColor = [ "#fabd2f" "bold" ];
          optionsTextColor = [ "#83a598" ];
          selectedLineBgColor = [ "#3c3836" ];
          cherryPickedCommitFgColor = [ "#d3869b" ];
          cherryPickedCommitBgColor = [ "#3c3836" ];
          unstagedChangesColor = [ "#fb4934" ];
          defaultFgColor = [ "#ebdbb2" ];
        };
      };
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --paging=never";
          }
        ];
        autoFetch = true;
        autoRefresh = true;
        log.showGraph = "always";
      };
      os.editPreset = "nvim";
      customCommands = [
        {
          key = "F";
          context = "commits";
          command = "git commit --fixup={{.SelectedLocalCommit.Hash}}";
          description = "Fixup this commit";
          loadingText = "Creating fixup...";
        }
        {
          key = "O";
          context = "global";
          command = "gh browse";
          description = "Open repo in browser";
        }
        {
          key = "P";
          context = "localBranches";
          command = "gh pr create --fill --web";
          description = "Create PR on GitHub";
          output = "terminal";
        }
      ];
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
      aliases = {
        co = "pr checkout";
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      syntax-theme = "gruvbox-dark";
      line-numbers = true;
      navigate = true;
      side-by-side = true;
      hyperlinks = true;
      width = "variable";
      merge-conflict-style = "zdiff3";
      true-color = "always";
      file-style = "bold yellow ul";
      file-decoration-style = "yellow ol";
      hunk-header-decoration-style = "blue box ul";
      hunk-header-style = "file line-number syntax";
      commit-decoration-style = "bold yellow box ul";
      commit-style = "bold yellow";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = let
    # Nix has no \u escape — decode Unicode via JSON
    u = cp: builtins.fromJSON ''"\u${cp}"'';
    pl-right = u "e0b0";       #
    pl-right-round = u "e0b6"; #
    pl-left-round = u "e0b4";  #
    prompt-char = u "f432";    #
    prompt-vim  = u "f434";    #
  in {
    enable = true;
    enableZshIntegration = true;
    settings = {
      command_timeout = 5000;
      palette = "gruvbox_dark";
      format = builtins.concatStringsSep "" [
        "[${pl-right-round}](color_orange)"
        "$username"
        "[${pl-right}](bg:color_yellow fg:color_orange)"
        "$directory"
        "[${pl-right}](fg:color_yellow bg:color_aqua)"
        "$git_branch"
        "$git_commit"
        "$git_status"
        "[${pl-right}](fg:color_aqua bg:color_blue)"
        "$c"
        "$rust"
        "$golang"
        "[${pl-right}](fg:color_blue bg:color_bg3)"
        "$docker_context"
        "[${pl-right}](fg:color_bg3)"
        " $character"
      ];
      right_format = "$python$cmd_duration$status $time";
      cmd_duration = {
        min_time = 3000;
        format = "[$duration ]($style)";
        style = "fg:color_yellow";
      };

      palettes.gruvbox_dark = {
        color_fg0 = "#fbf1c7";
        color_bg1 = "#3c3836";
        color_bg3 = "#665c54";
        color_blue = "#458588";
        color_aqua = "#689d6a";
        color_green = "#98971a";
        color_orange = "#d65d0e";
        color_purple = "#b16286";
        color_red = "#cc241d";
        color_yellow = "#d79921";
      };

      os.disabled = true;

      username = {
        show_always = false;
        style_user = "bg:color_orange fg:color_fg0";
        style_root = "bg:color_orange fg:color_fg0";
        format = "[ $user ]($style)";
      };
      directory = {
        style = "fg:color_fg0 bg:color_yellow";
        format = "[ $path ]($style)";
        truncation_length = 5;
        truncation_symbol = "…/";
        truncate_to_repo = false;
      };
      git_branch = {
        symbol = "";
        style = "bg:color_aqua";
        format = "[[ $symbol $branch(:$remote_branch) ](fg:color_fg0 bg:color_aqua)]($style)";
      };
      git_commit = {
        only_detached = true;
        format = "[[ $hash$tag ](fg:color_fg0 bg:color_aqua)]($style)";
        style = "bg:color_aqua";
        tag_disabled = false;
        tag_symbol = "  ";
      };
      # Show remote name when tracking differs from local
      git_branch.always_show_remote = false;
      git_status = {
        style = "bg:color_aqua";
        format = "[[($staged$modified$untracked$deleted$conflicted$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
        staged = "[+$count ](fg:color_fg0 bg:color_aqua)";
        modified = "[~$count ](fg:color_fg0 bg:color_aqua)";
        untracked = "[?$count ](fg:color_fg0 bg:color_aqua)";
        deleted = "[-$count ](fg:color_fg0 bg:color_aqua)";
        conflicted = "[!$count ](fg:color_fg0 bg:color_aqua)";
        stashed = "";
        ignore_submodules = true;
      };
      c = {
        symbol = " ";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };
      rust = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };
      golang = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };
      nodejs.disabled = true;
      python = {
        symbol = "";
        style = "fg:color_yellow";
        version_format = "$major.$minor.$patch";
        format = "[$symbol python$version( \\($virtualenv\\)) ]($style)";
      };
      docker_context = {
        symbol = "";
        style = "bg:color_bg3";
        format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
      };
      conda.disabled = true;
      pixi.disabled = true;
      status = {
        disabled = false;
        format = "[$symbol $status]($style)";
        symbol = "";
        style = "fg:color_red";
      };
      time = {
        disabled = false;
        time_format = "%R";
        style = "fg:color_yellow";
        format = "[$time]($style)";
      };
      line_break.disabled = true;
      character = {
        disabled = false;
        success_symbol = "[\\$](bold fg:color_green)";
        error_symbol = "[\\$](bold fg:color_red)";
        vimcmd_symbol = "[\\$](bold fg:color_green)";
        vimcmd_replace_one_symbol = "[\\$](bold fg:color_purple)";
        vimcmd_replace_symbol = "[\\$](bold fg:color_purple)";
        vimcmd_visual_symbol = "[\\$](bold fg:color_yellow)";
      };
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height=60%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline-right"
      "--color" "bg+:#3c3836,bg:#282828,spinner:#689d6a,hl:#d65d0e"
      "--color" "fg:#ebdbb2,header:#d65d0e,info:#d79921,pointer:#689d6a"
      "--color" "marker:#689d6a,fg+:#ebdbb2,prompt:#d79921,hl+:#d65d0e"
      "--bind=ctrl-/:toggle-preview"
    ];
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview" "'bat --color=always --style=numbers --line-range=:500 {}'"
      "--preview-window" "'right:60%:border-left'"
    ];
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview" "'eza --tree --color=always --icons --level=2 {}'"
    ];
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

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        controlMaster = "auto";
        controlPath = "~/.ssh/sockets/%r@%h-%p";
        controlPersist = "600";
        extraOptions = {
          UserKnownHostsFile = "/dev/null";
          StrictHostKeyChecking = "no";
        };
      };
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
      };
      "gold230" = {
        hostname = "gold230";
        user = "admin";
      };
      "ronan-vm" = {
        hostname = "ronan-vm.dev.us-west-1.nexthop.ai";
        user = "ronan";
        forwardAgent = true;
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 30;
        proxyCommand = "quicssh client --addr %h:60666 --session-layer --insecure --skip-verify-hostname";
      };
      "ronan-vm-ssh" = {
        hostname = "ronan-vm.dev.us-west-1.nexthop.ai";
        user = "ronan";
        forwardAgent = true;
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 30;
      };
      "ronan-vm.dev.us-west-1.nexthop.ai-ssh" = {
        hostname = "ronan-vm.dev.us-west-1.nexthop.ai";
        user = "ronan";
        forwardAgent = true;
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 30;
      };
      "ronan-vm.dev.us-west-1.nexthop.ai" = {
        hostname = "ronan-vm.dev.us-west-1.nexthop.ai";
        user = "ronan";
        forwardAgent = true;
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 30;
        proxyCommand = "quicssh client --addr %h:60666 --session-layer --insecure --skip-verify-hostname";
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Install npm-based CLI tools not in nixpkgs
  home.activation.installNpmTools = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    mkdir -p "$NPM_CONFIG_PREFIX"
    for bin_pkg in claude:@anthropic-ai/claude-code auggie:@augmentcode/auggie; do
      bin="''${bin_pkg%%:*}"
      pkg="''${bin_pkg#*:}"
      if ! "$NPM_CONFIG_PREFIX/bin/$bin" --version >/dev/null 2>&1; then
        ${pkgs.nodejs}/bin/npm install -g "$pkg" 2>/dev/null || true
      fi
    done
  '';
}
