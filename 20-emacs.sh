#!/bin/bash

# Modified Emacs theme hook that supports per-theme emacs.el files
# Falls back to ANSI color generation if emacs.el doesn't exist

theme_dir="$HOME/.config/omarchy/current/theme"
new_emacs_file="$theme_dir/omarchy-doom-theme.el"
custom_emacs_theme="$theme_dir/emacs.el"

create_dynamic_theme() {
    cat > "$new_emacs_file" << EOF
(autothemer-deftheme
 omarchy-doom "A theme for Omarchy Linux"
 ((((class color) (min-colors #xFFFFFF)))

   ;; Color palette from system theme
   (bg          "#${primary_background}")
   (fg          "#${primary_foreground}")
   (cursor-fg   "#${primary_background}")
   (cursor-bg   "#${cursor_color}")
   (sel-fg      "#${selection_foreground}")
   (sel-bg      "#${selection_background}")
   (black       "#${normal_black}")
   (red         "#${normal_red}")
   (green       "#${normal_green}")
   (yellow      "#${normal_yellow}")
   (blue        "#${normal_blue}")
   (magenta     "#${normal_magenta}")
   (cyan        "#${normal_cyan}")
   (white       "#${normal_white}")
   (br-black    "#${bright_black}")
   (br-red      "#${bright_red}")
   (br-green    "#${bright_green}")
   (br-yellow   "#${bright_yellow}")
   (br-blue     "#${bright_blue}")
   (br-magenta  "#${bright_magenta}")
   (br-cyan     "#${bright_cyan}")
   (br-white    "#${bright_white}")
   )

 ;; Face mappings (aligned with Zed/VSCode/Neovim mappings)
 (
  ;; Core faces
  (default                          (:foreground fg :background bg))
  (cursor                           (:foreground cursor-fg :background cursor-bg))
  (region                           (:foreground sel-fg :background sel-bg))
  (highlight                        (:background sel-bg))
  (shadow                           (:foreground br-black))
  (minibuffer-prompt                (:foreground blue :bold t))
  (link                             (:foreground blue :underline t))
  (link-visited                     (:foreground magenta :underline t))

  ;; Line numbers
  (line-number                      (:foreground br-black))
  (line-number-current-line         (:foreground br-red))

  ;; Search / match
  (isearch                          (:foreground bg :background yellow))
  (lazy-highlight                   (:foreground bg :background br-yellow))
  (match                            (:foreground bg :background blue))

  ;; Syntax highlighting
  (font-lock-keyword-face           (:foreground magenta))
  (font-lock-function-name-face     (:foreground blue))
  (font-lock-function-call-face     (:foreground blue))
  (font-lock-variable-name-face     (:foreground red))
  (font-lock-variable-use-face      (:foreground red))
  (font-lock-string-face            (:foreground green))
  (font-lock-doc-face               (:foreground green :italic t))
  (font-lock-comment-face           (:foreground br-black :italic t))
  (font-lock-comment-delimiter-face (:foreground br-black :italic t))
  (font-lock-constant-face          (:foreground br-red))
  (font-lock-number-face            (:foreground br-red))
  (font-lock-type-face              (:foreground yellow))
  (font-lock-builtin-face           (:foreground cyan))
  (font-lock-preprocessor-face      (:foreground cyan))
  (font-lock-negation-char-face     (:foreground red))
  (font-lock-warning-face           (:foreground yellow :bold t))
  (font-lock-regexp-grouping-construct (:foreground cyan))
  (font-lock-regexp-grouping-backslash (:foreground cyan))

  ;; Mode line
  (mode-line                        (:foreground fg :background black))
  (mode-line-inactive               (:foreground br-black :background black))
  (mode-line-emphasis               (:foreground blue :bold t))
  (mode-line-buffer-id              (:foreground fg :bold t))

  ;; Errors / warnings
  (error                            (:foreground red))
  (warning                          (:foreground yellow))
  (success                          (:foreground green))

  ;; Diff / version control
  (diff-added                       (:foreground green))
  (diff-removed                     (:foreground red))
  (diff-changed                     (:foreground magenta))
  (diff-header                      (:foreground blue :bold t))

  ;; Parens
  (show-paren-match                 (:foreground bg :background blue :bold t))
  (show-paren-mismatch              (:foreground bg :background red :bold t))

  ;; Whitespace
  (trailing-whitespace              (:background red))

  ;; Fringe and UI
  (fringe                           (:foreground br-black :background bg))
  (vertical-border                  (:foreground black))
 ))

(provide-theme 'omarchy-doom)
EOF
}

if ! command -v emacs >/dev/null 2>&1; then
    skipped "Emacs"
fi

# Check if theme has a custom emacs.el file
if [ -f "$custom_emacs_theme" ]; then
    echo "Using custom Emacs theme: $custom_emacs_theme"
    cp "$custom_emacs_theme" "$new_emacs_file"
else
    echo "Generating Emacs theme from colors.toml (ANSI mapping)"
    create_dynamic_theme
fi

emacsclient -e "(omarchy-themer-install-and-load \"$new_emacs_file\")"

success "Emacs theme updated!"
exit 0
