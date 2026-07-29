{ config, pkgs, lib, inputs, ... }: {

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
      # Reload shell cleanly: resets inherited blocked SIGCHLD before exec'ing zsh.
      rezsh = "exec python3 -c 'import signal,os; signal.pthread_sigmask(signal.SIG_SETMASK,set()); os.execvp(\"zsh\",[\"-zsh\"])'";
      hms = if pkgs.stdenv.isDarwin
        then "sudo darwin-rebuild switch --flake ~/.config/home-manager --impure"
        else "home-manager switch --flake ~/.config/home-manager --impure";
      gist = "gh gist create -";
      pip = "uv pip";
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
      # Raise per-process FD limit — macOS default (256–2560) is too low for
      # tools like nvim that watch large monorepos via libuv fs_event.
      ulimit -n 65536 2>/dev/null

      # Kitty shell integration — login shells only (exec zsh is non-login; running
      # kitty-integration in that context blocks on sysopen to the TTY).
      if [[ -o login ]] && [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
        export KITTY_SHELL_INTEGRATION="no-rc"
        autoload -Uz -- "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty-integration"
        kitty-integration
        unfunction kitty-integration
      fi

      # 1Password shell plugins — interactive only; non-interactive tools use GH_TOKEN or keychain
      [[ -o interactive ]] && [[ -f "$HOME/.config/op/plugins.sh" ]] && source "$HOME/.config/op/plugins.sh"

      # Auto-attach to tmux on SSH login
      if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && $- == *i* ]]; then
        tmux new-session -A -s main
      fi

      # Create tmux session + git worktree for a feature branch
      nw() {
        local name="$1"
        if [[ -z "$name" ]]; then
          echo "Usage: nw <name>"
          return 1
        fi

        local bare=~/repos/nh-bare
        local wt="$bare/$name"

        # Create worktree tracking ronan.<name>
        if [[ ! -d "$wt" ]]; then
          git -C "$bare" worktree add "$wt" -b "ronan.$name" 2>/dev/null \
            || git -C "$bare" worktree add "$wt" "ronan.$name"
        fi

        # Ensure .envrc exists and is allowed so direnv exec works
        if [[ ! -f "$wt/.envrc" ]]; then
          echo "layout python python3.13" > "$wt/.envrc"
        fi
        direnv allow "$wt"

        # Create tmux session with 3 windows
        tmux new-session -d -s "$name" -c "$wt" -n claude
        tmux send-keys -t "$name:claude" "direnv exec '$wt' claude" Enter
        tmux new-window -t "$name" -n shell -c "$wt"
        tmux new-window -t "$name" -n nvim -c "$wt"
        tmux send-keys -t "$name:nvim" "nvim" Enter

        # Attach or switch
        if [[ -z "$TMUX" ]]; then
          tmux attach -t "$name"
        else
          tmux switch-client -t "$name"
        fi
      }

      # Set up a direnv-managed Python venv in the current directory.
      # Usage: venv [python-version]  e.g. venv python3.11
      venv() {
        if [[ -f .envrc ]]; then
          echo ".envrc already exists"
          return 1
        fi
        echo "layout python ''${1:-python3.13}" > .envrc
        direnv allow
      }

      # Path-aware word deletion (stop at / . - instead of eating entire paths)
      WORDCHARS=''\'''${WORDCHARS//[\/.]}'
      setopt CORRECT INTERACTIVE_COMMENTS NO_BEEP

      # Allow backspace past insert-mode entry point (like non-vi shells)
      bindkey -v '^?' backward-delete-char
      bindkey -v '^H' backward-delete-char

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
          printf '\e]99;i=auto-notify:d=0;%s\a\e]99;i=auto-notify:d=1:p=body;%s\a' "$title" "$body"
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

      # zoxide — use source <() to avoid sigsuspend hang under exec zsh
      source <(${pkgs.zoxide}/bin/zoxide init zsh)

      # Non-login shells skip compdump rewrite (-D): compdump's $(typeset +fm '_*')
      # hangs under exec zsh due to inherited broken SIGCHLD state.
      autoload -U compinit
      if [[ -o login ]]; then
        compinit
      else
        compinit -C -D
      fi
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      if [[ $TERM != "dumb" ]]; then
        unset STARSHIP_SESSION_KEY STARSHIP_SHELL
        source <(starship init zsh 2>/dev/null)
        # starship init sets PROMPT/RPROMPT to '$()' which hangs in ZLE (child_block
        # is called before promptexpand). Compute in precmd instead, which runs
        # before ZLE acquires its child block.
        PROMPT=
        RPROMPT=
        _starship_render() {
          PROMPT="$(starship prompt --terminal-width="''${COLUMNS:-80}" --keymap="''${KEYMAP:-}" --status="''${STARSHIP_CMD_STATUS:-}" --pipestatus="''${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="''${STARSHIP_DURATION:-}" --jobs="''${STARSHIP_JOBS_COUNT:-0}")"
          RPROMPT="$(starship prompt --right --terminal-width="''${COLUMNS:-80}" --keymap="''${KEYMAP:-}" --status="''${STARSHIP_CMD_STATUS:-}" --pipestatus="''${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="''${STARSHIP_DURATION:-}" --jobs="''${STARSHIP_JOBS_COUNT:-0}")"
        }
        add-zsh-hook precmd _starship_render
        PROMPT2='$(starship prompt --continuation)'
      fi

      # direnv — use source <() to avoid sigsuspend hang under exec zsh
      source <(${pkgs.direnv}/bin/direnv hook zsh)
    '';
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
    enableZshIntegration = false;
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
        truncation_symbol = ".../";
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

  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
    nix-direnv.enable = true;
    stdlib = ''
      # Auto-load secrets from 1Password into every direnv environment.
      # Silent when op isn't installed (CI, offline); warns when installed
      # but not signed in so missing creds don't surprise you.
      if command -v op &>/dev/null; then
        if ${pkgs.coreutils}/bin/timeout 5 op whoami &>/dev/null; then
          export JIRA_TOKEN="$(${pkgs.coreutils}/bin/timeout 5 op read 'op://Nexthop/Jira/token' 2>/dev/null)"
          export JIRA_EMAIL="$(${pkgs.coreutils}/bin/timeout 5 op read 'op://Nexthop/Jira/email' 2>/dev/null)"
          export GITHUB_TOKEN="$(${pkgs.coreutils}/bin/timeout 5 op read 'op://Nexthop/Developer Tokens/token' 2>/dev/null)"
          export GH_TOKEN="$GITHUB_TOKEN"
          # jira-cli (ankitpokhrel)
          export JIRA_API_TOKEN="$JIRA_TOKEN"
          # acli (Atlassian official)
          export ATLASSIAN_API_TOKEN="$JIRA_TOKEN"
          export ATLASSIAN_EMAIL="$JIRA_EMAIL"
        else
          log_error "op not signed in — JIRA/GitHub tokens not exported. Run: eval \$(op signin)"
        fi
      fi

      # Name venvs after the project directory instead of python-X.Y
      # Uses uv for venv creation when available (10-100x faster)
      layout_python() {
        local python=''${1:-python3}
        local venv_name
        venv_name="$(basename "$PWD")"
        local venv=".direnv/$venv_name"

        if [[ ! -d "$venv" ]]; then
          local old_venv
          old_venv="$(find .direnv -maxdepth 1 -name 'python-*' -type d 2>/dev/null | head -1)"
          if [[ -n "$old_venv" ]]; then
            mv "$old_venv" "$venv"
          elif command -v uv &>/dev/null; then
            uv venv "$venv" --python "$python"
          else
            $python -m venv "$venv"
          fi
        fi

        export VIRTUAL_ENV="$PWD/$venv"
        PATH_add "$venv/bin"

        # Install dev tools in new venvs
        if [[ ! -f "$venv/.devtools-installed" ]]; then
          "$venv/bin/pip" install -q pdbpp debugpy 2>/dev/null && touch "$venv/.devtools-installed"
        fi
      }
    '';
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
  };
}
