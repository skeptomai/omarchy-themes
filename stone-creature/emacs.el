;; Stone Creature theme for Emacs
;; Light mode theme with warm stone background
;; Generated from neovim.lua color definitions

(autothemer-deftheme
 omarchy-doom "Stone Creature - A light mode theme for Omarchy Linux"
 ((((class color) (min-colors #xFFFFFF)))

   ;; Color palette (from neovim.lua)
   (bg          "#d8d5cd")
   (bg-dark     "#cbc8c0")
   (bg-highlight "#c3c0b8")
   (fg          "#2e2e2e")
   (fg-dark     "#5c5f77")
   (comment     "#9ca0b0")

   ;; Syntax colors (aligned with neovim.lua)
   (red         "#d20f39")
   (orange      "#fe640b")
   (yellow      "#b85400")
   (green       "#40a02b")
   (cyan        "#179299")
   (blue        "#1e66f5")
   (purple      "#8839ef")
   (magenta     "#8839ef")

   ;; Cursor and selection
   (cursor-fg   "#d8d5cd")
   (cursor-bg   "#2e2e2e")
   (sel-fg      "#d8d5cd")
   (sel-bg      "#1e66f5")

   ;; ANSI colors (for compatibility)
   (black       "#2e2e2e")
   (white       "#d8d5cd")
   (br-black    "#5c5f77")
   (br-red      "#fe640b")
   (br-green    "#40a02b")
   (br-yellow   "#b85400")
   (br-blue     "#1e66f5")
   (br-magenta  "#8839ef")
   (br-cyan     "#179299")
   (br-white    "#e8e8e8")
   )

 ;; Face mappings (aligned with 20-emacs.sh)
 (
  ;; Core faces
  (default                          (:foreground fg :background bg))
  (cursor                           (:foreground cursor-fg :background cursor-bg))
  (region                           (:foreground sel-fg :background sel-bg))
  (highlight                        (:background sel-bg))
  (shadow                           (:foreground comment))
  (minibuffer-prompt                (:foreground blue :bold t))
  (link                             (:foreground blue :underline t))
  (link-visited                     (:foreground magenta :underline t))

  ;; Line numbers
  (line-number                      (:foreground comment))
  (line-number-current-line         (:foreground orange))

  ;; Search / match
  (isearch                          (:foreground bg :background yellow))
  (lazy-highlight                   (:foreground bg :background br-yellow))
  (match                            (:foreground bg :background blue))

  ;; Syntax highlighting
  (font-lock-keyword-face           (:foreground purple))
  (font-lock-function-name-face     (:foreground blue))
  (font-lock-function-call-face     (:foreground blue))
  (font-lock-variable-name-face     (:foreground red))
  (font-lock-variable-use-face      (:foreground red))
  (font-lock-string-face            (:foreground green))
  (font-lock-doc-face               (:foreground green :italic t))
  (font-lock-comment-face           (:foreground comment :italic t))
  (font-lock-comment-delimiter-face (:foreground comment :italic t))
  (font-lock-constant-face          (:foreground orange))
  (font-lock-number-face            (:foreground orange))
  (font-lock-type-face              (:foreground yellow))
  (font-lock-builtin-face           (:foreground cyan))
  (font-lock-preprocessor-face      (:foreground cyan))
  (font-lock-negation-char-face     (:foreground red))
  (font-lock-warning-face           (:foreground yellow :bold t))
  (font-lock-regexp-grouping-construct (:foreground cyan))
  (font-lock-regexp-grouping-backslash (:foreground cyan))

  ;; Mode line
  (mode-line                        (:foreground fg :background bg-dark))
  (mode-line-inactive               (:foreground comment :background bg-dark))
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
  (fringe                           (:foreground comment :background bg))
  (vertical-border                  (:foreground bg-dark))
 ))

(provide-theme 'omarchy-doom)
