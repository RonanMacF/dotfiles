{ config, pkgs, ... }: {

  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;
    initLua = ''
      require("config.lazy")
    '';
  };

  programs.kitty = {
    enable = true;
    # On macOS, Kitty is installed via Homebrew cask (darwin.nix).
    # On Linux, Nix provides the package (for terminfo + kitten).
    package = if pkgs.stdenv.isDarwin then pkgs.emptyDirectory else pkgs.kitty;
    shellIntegration.enableZshIntegration = false;
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
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/sockets/%r@%h-%p";
        ControlPersist = "600";
        UserKnownHostsFile = "/dev/null";
        StrictHostKeyChecking = "no";
      };
      "github.com" = {
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "gold230" = {
        HostName = "gold230";
        User = "admin";
      };
      # QUIC transport (default for short alias and FQDN)
      "ronan-vm" = {
        HostName = "ronan-vm.dev.us-west-1.nexthop.ai";
        User = "ronan";
        ForwardAgent = true;
        IdentityFile = "~/.ssh/id_ed25519";
        # quicssh --session-layer owns liveness; disable ssh's keepalive watchdog so
        # it waits patiently while quicssh resumes the session across sleep/VPN drops.
        ServerAliveInterval = 0;
        ProxyCommand = "quicssh client --addr %h:60666 --idle-timeout 20s --session-layer --insecure --skip-verify-hostname";
      };
      "ronan-vm.dev.us-west-1.nexthop.ai" = {
        HostName = "ronan-vm.dev.us-west-1.nexthop.ai";
        User = "ronan";
        ForwardAgent = true;
        IdentityFile = "~/.ssh/id_ed25519";
        # quicssh --session-layer owns liveness; disable ssh's keepalive watchdog so
        # it waits patiently while quicssh resumes the session across sleep/VPN drops.
        ServerAliveInterval = 0;
        ProxyCommand = "quicssh client --addr %h:60666 --idle-timeout 20s --session-layer --insecure --skip-verify-hostname";
      };
      # Direct SSH fallback (no QUIC)
      "ronan-vm-ssh ronan-vm.dev.us-west-1.nexthop.ai-ssh" = {
        HostName = "ronan-vm.dev.us-west-1.nexthop.ai";
        User = "ronan";
        ForwardAgent = true;
        IdentityFile = "~/.ssh/id_ed25519";
        ServerAliveInterval = 30;
      };
    };
  };
}
