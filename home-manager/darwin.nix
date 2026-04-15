{ pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;
  users.users.ronan.home = "/Users/ronan";
  system.primaryUser = "ronan";

  # Homebrew — nix-darwin manages casks declaratively
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
    };
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

  system.stateVersion = 5;
}
