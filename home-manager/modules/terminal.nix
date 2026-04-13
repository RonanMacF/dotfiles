{ config, pkgs, ... }: {

  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;
    # Plugins managed by LazyVim in ~/.config/nvim/
  };

  programs.kitty = {
    enable = true;
    # On macOS, Kitty is installed via Homebrew cask (darwin.nix).
    # On Linux, Nix provides the package (for terminfo + kitten).
    package = if pkgs.stdenv.isDarwin then pkgs.emptyDirectory else pkgs.kitty;
    shellIntegration.enableZshIntegration = true;
    extraConfig = builtins.readFile "${config.home.homeDirectory}/dotfiles/kitty/kitty.conf";
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
      style = "numbers,changes";
    };
  };

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
      # QUIC transport (default for short alias and FQDN)
      "ronan-vm" = {
        hostname = "ronan-vm.dev.us-west-1.nexthop.ai";
        user = "ronan";
        forwardAgent = true;
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 30;
        proxyCommand = "quicssh client --addr %h:60666 --session-layer --insecure --skip-verify-hostname";
      };
      "ronan-vm.dev.us-west-1.nexthop.ai" = {
        hostname = "ronan-vm.dev.us-west-1.nexthop.ai";
        user = "ronan";
        forwardAgent = true;
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 30;
        proxyCommand = "quicssh client --addr %h:60666 --session-layer --insecure --skip-verify-hostname";
      };
      # Direct SSH fallback (no QUIC)
      "ronan-vm-ssh ronan-vm.dev.us-west-1.nexthop.ai-ssh" = {
        hostname = "ronan-vm.dev.us-west-1.nexthop.ai";
        user = "ronan";
        forwardAgent = true;
        identityFile = "~/.ssh/id_ed25519";
        serverAliveInterval = 30;
      };
    };
  };
}
