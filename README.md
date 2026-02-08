# Omarchy Themes Collection

A collection of custom themes for Omarchy Linux.

## Themes

### Stone Creature
A light mode theme with warm stone/beige backgrounds and dark text, inspired by limestone gargoyles.

**Features:**
- Light mode with warm beige background (#d8d5cd)
- Dark text for excellent readability
- Burnt orange accent for types/constructors (#b85400)
- Optimized for terminals (Ghostty, Alacritty, Kitty) and editors (Emacs, Neovim)

**Theme Directory:** `stone-creature/`

### Field of Dreams
[Add description]

**Theme Directory:** `field-of-dreams/`

## Installation

Each theme can be installed by copying its directory to `~/.config/omarchy/themes/` or `~/.local/share/omarchy/themes/`.

```bash
# Install a theme
cp -r stone-creature ~/.config/omarchy/themes/

# Or use the Omarchy theme manager
# Super + Space > Install > Theme
```

## Theme Structure

Each theme directory contains:
- `colors.toml` - Core color palette (source of truth)
- `*.(conf|toml)` - Terminal configurations
- `neovim.lua` - Neovim/editor configuration
- `backgrounds/` - Wallpaper images
- `light.mode` - Optional file indicating light mode theme

## Contributing

To add a new theme, create a subdirectory with the theme files following the structure above.
