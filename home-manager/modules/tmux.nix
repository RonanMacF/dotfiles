{ pkgs, ... }: {

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
    extraConfig = ''
      # True color support — tell tmux that the outer terminal supports RGB
      set -ga terminal-overrides ",xterm-kitty:Tc,tmux-256color:Tc"

      # OSC 8 hyperlink support — tmux strips OSC 8 unless Hls is advertised
      set -as terminal-features ",xterm-kitty:hyperlinks"
      set -as terminal-features ",tmux-256color:hyperlinks"

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

      # Sesh session picker; a typed name with no match becomes a new session
      bind "T" run-shell "sel=\"$(
        sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '  ' \
          --print-query \
          --header '  ^a all ^t tmux ^x zoxide ^d kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-x:change-prompt(  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}' \
          | tail -1
        )\"; [ -n \"$sel\" ] || exit 0; sesh connect \"$sel\" 2>/dev/null ||
        { tmux new-session -d -s \"$sel\" -c \"#{pane_current_path}\" && tmux switch-client -t \"=$sel\"; } || true"

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
      set -g @continuum-boot 'on'
    '';
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      resurrect
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
      # Load continuum LAST so its periodic-save hook lands on top of
      # catppuccin's status-right (otherwise catppuccin clobbers it and
      # automatic saves silently stop — what caused the 2026-06-03 gap).
      continuum
    ];
  };
}
