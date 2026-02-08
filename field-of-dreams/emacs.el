;; Field of Dreams theme for Emacs
;; Brutalist dark mode theme with cold industrial colors
;; Generated from neovim.lua color definitions

(autothemer-deftheme
 omarchy-doom "Field of Dreams - A brutalist theme for Omarchy Linux"
 ((((class color) (min-colors #xFFFFFF)))

   ;; Color palette (from neovim.lua)
   (bg          "#17181a")
   (bg-dark     "#0f1012")
   (bg-highlight "#2a2a2a")
   (fg          "#d4d4d4")
   (fg-dark     "#9a9a9a")
   (comment     "#6a6a6a")

   ;; Syntax colors (aligned with neovim.lua)
   (red         "#b85d5d")
   (orange      "#997a5d")
   (yellow      "#a89b6b")
   (green       "#7a9b7a")
   (cyan        "#669999")
   (blue        "#6b8199")
   (purple      "#8d7a99")
   (magenta     "#997a8d")

   ;; Cursor and selection
   (cursor-fg   "#17181a")
   (cursor-bg   "#d4d4d4")
   (sel-fg      "#17181a")
   (sel-bg      "#6b8199")

   ;; ANSI colors (for compatibility)
   (black       "#17181a")
   (white       "#d4d4d4")
   (br-black    "#4a4a4a")
   (br-red      "#c97676")
   (br-green    "#8fb18f")
   (br-yellow   "#bdb088")
   (br-blue     "#7d96b0")
   (br-magenta  "#b08fa2")
   (br-cyan     "#7db3b3")
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
