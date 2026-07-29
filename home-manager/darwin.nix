{ pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (final: prev: {
      direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });
    })
  ];
  users.users.ronan.home = "/Users/ronan";
  system.primaryUser = "ronan";

  # Homebrew — nix-darwin manages casks declaratively
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
    };
    taps = [
      "atlassian/acli"
    ];
    brews = [
      "atlassian/acli/acli"
    ];
    casks = [
      "maccy"
      "kitty"
    ];
  };

  # macOS system defaults
  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      tilesize = 48;
      show-recents = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      "com.apple.swipescrolldirection" = true;
    };
    screencapture.location = "/Users/ronan/Desktop/Screenshots";
  };

  # Ensure Screenshots directory exists for screencapture.location
  system.activationScripts.postActivation.text = ''
    mkdir -p /Users/ronan/Desktop/Screenshots
  '';

  # Raise kernel FD ceilings — macOS default kern.maxfilesperproc (92160)
  # caps any process regardless of `ulimit -n`. Hit by nvim LSP watchers
  # in monorepos like sonic-mgmt that fs_event tens of thousands of dirs.
  launchd.daemons.limit-maxfiles = {
    script = "launchctl limit maxfiles 524288 1048576";
    serviceConfig = {
      Label = "limit.maxfiles";
      RunAtLoad = true;
      ServiceIPC = false;
    };
  };
  launchd.daemons.sysctl-maxfiles = {
    script = ''
      sysctl -w kern.maxfiles=1048576
      sysctl -w kern.maxfilesperproc=524288
    '';
    serviceConfig = {
      Label = "sysctl.maxfiles";
      RunAtLoad = true;
      ServiceIPC = false;
    };
  };

  system.stateVersion = 5;
}
