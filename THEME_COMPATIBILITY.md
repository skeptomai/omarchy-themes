# Omarchy Theme Compatibility Report

## Overview

All 16 Omarchy themes successfully convert to Emacs themes using the integrated hook system.

## Conversion Tiers

### Tier 1: Explicit emacs.el
- **Usage**: When theme author provides a hand-crafted `emacs.el` file
- **Themes**: None currently use this (all rely on automatic conversion)
- **Action**: Direct copy, no conversion needed

### Tier 2: neovim.lua Conversion (High Fidelity)
- **Usage**: Themes with inline color definitions in `neovim.lua`
- **Method**: Lua extraction + semantic color mapping
- **Themes**: 2 themes
  - `stone-creature` - Light mode theme with warm stone palette
  - `field-of-dreams` - Dark brutalist industrial theme

**Characteristics**:
- Full semantic color palette (bg, fg, bg_dark, comment, etc.)
- Prescriptive syntax highlighting (types=yellow, functions=blue, etc.)
- Best fidelity for complex color schemes

### Tier 3: colors.toml Fallback (ANSI Mapping)
- **Usage**: Plugin-based themes without inline colors
- **Method**: Parse ANSI colors from `colors.toml`
- **Themes**: 14 themes
  - `catppuccin` - Mocha dark theme
  - `catppuccin-latte` - Light pastel theme
  - `ethereal` - Soft atmospheric theme
  - `everforest` - Warm forest green theme
  - `flexoki-light` - Light organic theme
  - `gruvbox` - Retro warm theme
  - `hackerman` - Matrix-style green on black
  - `kanagawa` - Japanese wave-inspired theme
  - `matte-black` - Minimal dark theme
  - `nord` - Arctic cool theme
  - `osaka-jade` - Japanese jade theme
  - `ristretto` - Coffee-inspired brown theme
  - `rose-pine` - Muted pastel theme
  - `tokyo-night` - Neon city theme

**Characteristics**:
- Uses standard ANSI color mapping (16 colors)
- Syntax: keywords=magenta, functions=blue, strings=green, etc.
- Good compatibility with standard terminal-based themes

## Test Results

### All Themes Status
```
Theme                Tier                     Lines  Status
─────────────────────────────────────────────────────────────
catppuccin           Tier 3 (colors.toml)     60     ✓
catppuccin-latte     Tier 3 (colors.toml)     60     ✓
ethereal             Tier 3 (colors.toml)     60     ✓
everforest           Tier 3 (colors.toml)     60     ✓
field-of-dreams      Tier 2 (neovim.lua)      60     ✓
flexoki-light        Tier 3 (colors.toml)     60     ✓
gruvbox              Tier 3 (colors.toml)     60     ✓
hackerman            Tier 3 (colors.toml)     60     ✓
kanagawa             Tier 3 (colors.toml)     60     ✓
matte-black          Tier 3 (colors.toml)     60     ✓
nord                 Tier 3 (colors.toml)     60     ✓
osaka-jade           Tier 3 (colors.toml)     60     ✓
ristretto            Tier 3 (colors.toml)     60     ✓
rose-pine            Tier 3 (colors.toml)     60     ✓
stone-creature       Tier 2 (neovim.lua)      60     ✓
tokyo-night          Tier 3 (colors.toml)     60     ✓
```

**Success Rate**: 16/16 (100%)

## Sample Theme Outputs

### Tier 2 Example (stone-creature)
```elisp
(bg "#d8d5cd") (bg-dark "#cbc8c0") (bg-highlight "#c3c0b8")
(fg "#2e2e2e") (fg-dark "#5c5f77") (comment "#9ca0b0")
(red "#d20f39") (orange "#fe640b") (yellow "#b85400") (green "#40a02b")
(cyan "#179299") (blue "#1e66f5") (purple "#8839ef") (magenta "#8839ef")
```

### Tier 3 Example (catppuccin)
```elisp
(bg "#1e1e2e") (fg "#cdd6f4")
(black "#45475a") (red "#f38ba8") (green "#a6e3a1")
(yellow "#f9e2af") (blue "#89b4fa") (magenta "#f5c2e7")
(cyan "#94e2d5") (white "#bac2de")
```

## Implementation Details

### Tier 2 Process
1. Load `neovim.lua` with Lua interpreter (nvim -l)
2. Extract color table from `opts.colors`
3. Validate hex colors and required fields
4. Generate Emacs theme with semantic mappings
5. Install and load in Emacs

### Tier 3 Process
1. Parse `colors.toml` with pure bash
2. Extract foreground, background, and 16 ANSI colors
3. Map to standard Emacs face names
4. Generate theme with ANSI-based mappings
5. Install and load in Emacs

## Technical Notes

### neovim.lua Structure Detection
The hook detects Tier 2 compatibility by checking if `neovim.lua` contains a `colors` table:
- **Tier 2 Compatible**: `opts = { colors = { bg = "#...", fg = "#...", ... } }`
- **Tier 3 Fallback**: `opts = { colorscheme = "plugin-name" }`

### colors.toml Format
All themes provide a standard format:
```toml
foreground = "#xxxxxx"
background = "#xxxxxx"
color0 = "#xxxxxx"  # black
color1 = "#xxxxxx"  # red
...
color15 = "#xxxxxx"  # bright white
```

## Future Enhancements

1. **Tier 1 Adoption**: Theme authors can provide hand-crafted `emacs.el` for maximum control
2. **Hybrid Approach**: Combine Tier 2 colors with Tier 1 custom face definitions
3. **Color Validation**: Add checks for contrast ratios and accessibility
4. **Theme Metadata**: Include author, description, and palette info in generated themes

## Deployment

- **Location**: `~/.config/omarchy/hooks/theme-set.d/20-emacs.sh`
- **Trigger**: Automatically runs when theme is changed via `omarchy-theme-set`
- **Emacs Integration**: Uses `omarchy-themer-install-and-load` for live updates
- **Status**: Fully deployed and operational

## Conclusion

The integrated hook system provides universal Emacs theme support across all Omarchy themes, with intelligent fallback ensuring compatibility regardless of theme structure.
