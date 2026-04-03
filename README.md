# dotfiles

Personal development environment managed with [Nix](https://nixos.org/) and [home-manager](https://github.com/nix-community/home-manager).

## Quick start

```bash
# 1. Install Nix
curl -L https://nixos.org/nix/install | sh

# 2. Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# 3. Clone this repo
git clone <repo-url> ~/dotfiles

# 4. Bootstrap (installs home-manager and activates the config)
nix run home-manager -- switch --flake ~/dotfiles/home-manager --impure
```

After the first run, rebuild with:

```bash
hms
```

## Updating

```bash
cd ~/dotfiles/home-manager

# Update all dependencies (nixpkgs, home-manager, plugins)
nix flake update

# Update a single input
nix flake update zsh-auto-notify

# Rebuild
hms
```

## Structure

```
home-manager/
  flake.nix       # Nix flake — pins nixpkgs, home-manager, and zsh plugins
  flake.lock      # Lockfile — exact versions for reproducible builds
  home.nix        # Home-manager config — packages, shell, git, kitty, etc.
kitty/            # Kitty terminal config
nvim/             # Neovim config (managed by LazyVim)
tmux/             # Tmux config
zsh/              # Zsh dotfiles (.p10k.zsh, etc.)
```

## Notes

- `--impure` is required because `home.nix` reads config files from `~/dotfiles/` at build time.
- On macOS, the Kitty notification fix runs automatically via a home-manager activation script (re-signs the binary and registers it with the notification center).
- The config auto-detects macOS vs Linux — same `home.nix` works on both.
