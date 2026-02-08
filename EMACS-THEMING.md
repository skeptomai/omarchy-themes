# Emacs Theming System

## Overview

This repository uses a **prescriptive theming system** for Emacs, similar to how `neovim.lua` works for Neovim. Each theme can define explicit colors for Emacs faces rather than relying on ANSI color mappings.

## How It Works

### Theme Structure

Each theme directory contains:
```
stone-creature/
├── colors.toml          # Base palette for terminals
├── neovim.lua           # Neovim-specific colors
├── emacs.el             # Emacs-specific colors (NEW)
├── ghostty.conf         # Terminal configs
└── backgrounds/
```

### The Flow

```
Option 1 (Prescriptive - Preferred):
emacs.el → 20-emacs.sh copies → omarchy-doom-theme.el → Emacs

Option 2 (Fallback):
colors.toml → theme-set extracts ANSI → 20-emacs.sh generates → Emacs
```

## emacs.el File Format

The `emacs.el` file uses the `autothemer-deftheme` format, matching the structure of the generated themes:

```elisp
(autothemer-deftheme
 omarchy-doom "Theme description"
 ((((class color) (min-colors #xFFFFFF)))

   ;; Color palette
   (bg          "#hexcolor")
   (fg          "#hexcolor")
   (red         "#hexcolor")
   ;; ... more colors
   )

 ;; Face mappings
 (
  (default (:foreground fg :background bg))
  (font-lock-type-face (:foreground yellow))
  ;; ... more faces
 ))
```

## Color Mapping (neovim.lua → emacs.el)

Colors defined in `neovim.lua` are mapped to Emacs faces in `emacs.el`:

| neovim.lua | Usage | Emacs Faces |
|------------|-------|-------------|
| `red` | Errors, variables | `error`, `font-lock-variable-name-face`, `diff-removed` |
| `orange` | Constants, numbers | `font-lock-constant-face`, `font-lock-number-face` |
| `yellow` | Types, warnings | `font-lock-type-face`, `warning` |
| `green` | Strings, success | `font-lock-string-face`, `diff-added` |
| `cyan` | Builtins, regex | `font-lock-builtin-face`, `font-lock-preprocessor-face` |
| `blue` | Functions, keywords | `font-lock-function-name-face`, `minibuffer-prompt` |
| `purple` | Keywords | `font-lock-keyword-face` |
| `magenta` | Special | `link-visited`, `diff-changed` |
| `comment` | Comments | `font-lock-comment-face`, `shadow` |

## Complete Face List

The `emacs.el` files define these faces (from `20-emacs.sh`):

### Core Faces
- `default`, `cursor`, `region`, `highlight`, `shadow`
- `minibuffer-prompt`, `link`, `link-visited`

### Syntax Highlighting
- `font-lock-keyword-face`
- `font-lock-function-name-face`, `font-lock-function-call-face`
- `font-lock-variable-name-face`, `font-lock-variable-use-face`
- `font-lock-string-face`, `font-lock-doc-face`
- `font-lock-comment-face`, `font-lock-comment-delimiter-face`
- `font-lock-constant-face`, `font-lock-number-face`
- `font-lock-type-face`
- `font-lock-builtin-face`, `font-lock-preprocessor-face`
- `font-lock-negation-char-face`, `font-lock-warning-face`
- `font-lock-regexp-grouping-construct`, `font-lock-regexp-grouping-backslash`

### UI Elements
- `line-number`, `line-number-current-line`
- `isearch`, `lazy-highlight`, `match`
- `mode-line`, `mode-line-inactive`, `mode-line-emphasis`, `mode-line-buffer-id`
- `fringe`, `vertical-border`
- `trailing-whitespace`

### Status & Diff
- `error`, `warning`, `success`
- `diff-added`, `diff-removed`, `diff-changed`, `diff-header`
- `show-paren-match`, `show-paren-mismatch`

## Installation

To use the new prescriptive system:

1. **Install the modified hook:**
   ```bash
   cp ~/Projects/omarchy-themes/20-emacs.sh ~/.config/omarchy/hooks/theme-set.d/20-emacs.sh
   chmod +x ~/.config/omarchy/hooks/theme-set.d/20-emacs.sh
   ```

2. **Sync themes to deployed location:**
   ```bash
   cp -r ~/Projects/omarchy-themes/*/emacs.el ~/.local/share/omarchy/themes/
   ```

3. **Switch themes** using Omarchy theme manager - the hook will automatically use `emacs.el` if present

## Benefits

- ✅ **Complete control** over Emacs colors
- ✅ **Consistency** with Neovim theming approach
- ✅ **Theme-specific** color semantics
- ✅ **Fallback support** for themes without `emacs.el`
- ✅ **Aligned** with neovim.lua color definitions

## Creating New Themes

When creating a new theme:

1. Define colors in `neovim.lua` first
2. Copy one of the existing `emacs.el` files as a template
3. Update the color palette section with your theme's colors
4. The face mappings can usually stay the same
5. Test by switching themes
