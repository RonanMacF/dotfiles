# nix-darwin + home-manager Integration

## Summary

Integrate nix-darwin into the existing home-manager flake so macOS system settings and GUI apps (via Homebrew casks) are managed declaratively alongside the cross-platform home-manager config. Linux stays as standalone home-manager — no change.

## File Structure

```
~/dotfiles/home-manager/
├── flake.nix      # single flake — darwinConfigurations + homeConfigurations
├── flake.lock
├── home.nix       # cross-platform (unchanged minus macOS hacks)
├── darwin.nix     # macOS-only: system defaults, Homebrew casks
```

## flake.nix

- Add `nix-darwin` input, following nixpkgs
- `darwinConfigurations."ronans-mbp"`: nix-darwin system with home-manager as a darwin module
- `homeConfigurations."ronan@ronan-vm"`: standalone home-manager for Linux (unchanged)
- Remove macOS `homeConfigurations` entries ("ronan", "ronan@ronans-mbp.lan") — replaced by darwinConfigurations

## darwin.nix

**Homebrew casks (declarative):**
- maccy
- kitty

**Settings:**
- `onActivation.autoUpdate = true`
- `onActivation.cleanup = "uninstall"` — removes unlisted casks

**macOS system defaults:**
- Dock: autohide, tilesize 48, no recents, no MRU spaces
- Finder: show all extensions, list view, show path bar
- Keyboard: InitialKeyRepeat 15, KeyRepeat 2 (fast for vim)
- Natural scrolling enabled
- Screenshots to ~/Screenshots

**System:**
- `services.nix-daemon.enable = true`
- `system.stateVersion = 5`

## home.nix Changes

1. Remove `maccy` from Darwin-only packages
2. Delete `fixKittyNotifications` activation script (~40 lines)
3. Delete `registerKittyNotifications` activation script (~40 lines)
4. Keep `programs.kitty` config block (terminfo on Linux, config on both)
5. Conditionalize `hms` alias:
   - macOS: `darwin-rebuild switch --flake ~/.config/home-manager`
   - Linux: `home-manager switch --flake ~/.config/home-manager --impure`

## Aliases

- macOS: `hms` = `darwin-rebuild switch --flake ~/.config/home-manager`
- Linux: `hms` = `home-manager switch --flake ~/.config/home-manager --impure`

## Bootstrap

**macOS (one-time):**
```bash
nix run nix-darwin -- switch --flake ~/.config/home-manager
```
After that: `hms`

**Linux:** No change.
