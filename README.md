# dotfiles

Cross-platform dev environment: [nix-darwin](https://github.com/LnL7/nix-darwin) (macOS) + [home-manager](https://github.com/nix-community/home-manager) (both platforms).

## Structure

```
home-manager/
  flake.nix           — single flake: darwinConfigurations + homeConfigurations
  home.nix            — packages, session vars, imports modules
  darwin.nix          — macOS-only: system defaults, Homebrew casks
  modules/
    shell.nix         — zsh, starship, fzf, direnv, zoxide
    tmux.nix          — tmux config, plugins, sesh session picker
    git.nix           — git, delta, lazygit, gh, template hooks
    terminal.nix      — neovim, kitty, bat, SSH
kitty/                  — kitty.conf (referenced by terminal.nix)
nvim/                   — LazyVim config (managed outside Nix)
zsh/                    — zsh history and completion cache (dotDir target)
```

## Usage

```bash
hms    # rebuilds everything — aliased per platform
```

- **macOS:** `darwin-rebuild switch --flake ~/.config/home-manager`
- **Linux:** `home-manager switch --flake ~/.config/home-manager --impure`

## Bootstrap

**macOS (first time):**
```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh

# Install Homebrew (needed for GUI app casks)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Symlink and build
ln -sf ~/dotfiles/home-manager ~/.config/home-manager
nix run nix-darwin -- switch --flake ~/.config/home-manager
```

**Linux (first time):**
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh
ln -sf ~/dotfiles/home-manager ~/.config/home-manager
home-manager switch --flake ~/.config/home-manager --impure
```

## Updating

```bash
cd ~/dotfiles/home-manager
nix flake update         # update all inputs
hms                      # rebuild
```

## Notes

- `--impure` is needed because `terminal.nix` reads kitty.conf via `builtins.readFile` from outside the Nix store.
- macOS GUI apps (Kitty, Maccy) are managed as Homebrew casks via nix-darwin — not Nix packages.
- Same `home.nix` works on both platforms; platform-specific logic uses `pkgs.stdenv.isDarwin`/`isLinux`.
