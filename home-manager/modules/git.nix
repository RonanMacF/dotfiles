{ config, pkgs, ... }: {

  programs.git = {
    enable = true;
    package = pkgs.git;
    # Disable fsmonitor for temp dirs — FSEvents is unreliable under
    # /private/tmp and /var/folders (macOS $TMPDIR) and causes
    # "could not read IPC response" errors.
    includes = [
      { condition = "gitdir:/tmp/"; contents.core.fsmonitor = false; }
      { condition = "gitdir:/private/tmp/"; contents.core.fsmonitor = false; }
      { condition = "gitdir:/var/folders/"; contents.core.fsmonitor = false; }
      { condition = "gitdir:/private/var/folders/"; contents.core.fsmonitor = false; }
    ];
    ignores = [
      ".direnv"
      ".envrc"
      "pyrightconfig.json"
      "**/.claude/settings.local.json"
    ];
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
        dft = "!f() { GIT_EXTERNAL_DIFF=difft git diff \"$@\"; }; f";
        dftl = "!f() { GIT_EXTERNAL_DIFF=difft git log -p \"$@\"; }; f";
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
      };
      help.autocorrect = "prompt";
      commit.verbose = true;
      commit.gpgSign = true;
      commit.signoff = true;
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
}
