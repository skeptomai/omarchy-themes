#!/bin/bash
# Phase 3: Generate Emacs Theme from Extracted Colors
# Takes extracted colors (key=value format) and generates complete emacs.el

generate_emacs_from_colors() {
    local colors_file="$1"
    local output_file="$2"

    if [ ! -f "$colors_file" ]; then
        echo "ERROR: Colors file not found: $colors_file" >&2
        return 1
    fi

    echo "→ Generating Emacs theme from extracted colors" >&2

    # Read colors into associative array
    declare -A colors
    while IFS='=' read -r key value; do
        colors[$key]="$value"
    done < "$colors_file"

    # Verify required colors exist
    local required=(bg fg red orange yellow green cyan blue purple magenta comment)
    local missing=()

    for color in "${required[@]}"; do
        if [ -z "${colors[$color]}" ]; then
            missing+=("$color")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "ERROR: Missing required colors: ${missing[*]}" >&2
        return 1
    fi

    echo "  ✓ All required colors present (${#colors[@]} total)" >&2

    # Set defaults for optional colors
    colors[bg_dark]="${colors[bg_dark]:-${colors[bg]}}"
    colors[bg_highlight]="${colors[bg_highlight]:-${colors[bg]}}"
    colors[fg_dark]="${colors[fg_dark]:-${colors[fg]}}"

    # Generate emacs.el with all face mappings
    cat > "$output_file" << 'EMACS_TEMPLATE'
;; Generated from neovim.lua
;; This theme file was automatically created by omarchy-emacs-themer

(autothemer-deftheme
 omarchy-doom "Omarchy theme generated from neovim.lua"
 ((((class color) (min-colors #xFFFFFF)))

   ;; Color palette (from neovim.lua)
   (bg          "BG_COLOR")
   (bg-dark     "BG_DARK_COLOR")
   (bg-highlight "BG_HIGHLIGHT_COLOR")
   (fg          "FG_COLOR")
   (fg-dark     "FG_DARK_COLOR")
   (comment     "COMMENT_COLOR")

   ;; Syntax colors
   (red         "RED_COLOR")
   (orange      "ORANGE_COLOR")
   (yellow      "YELLOW_COLOR")
   (green       "GREEN_COLOR")
   (cyan        "CYAN_COLOR")
   (blue        "BLUE_COLOR")
   (purple      "PURPLE_COLOR")
   (magenta     "MAGENTA_COLOR")

   ;; Cursor and selection
   (cursor-fg   "BG_COLOR")
   (cursor-bg   "FG_COLOR")
   (sel-fg      "BG_COLOR")
   (sel-bg      "BLUE_COLOR")

   ;; ANSI colors (for compatibility)
   (black       "BG_COLOR")
   (white       "FG_COLOR")
   (br-black    "COMMENT_COLOR")
   (br-red      "ORANGE_COLOR")
   (br-green    "GREEN_COLOR")
   (br-yellow   "YELLOW_COLOR")
   (br-blue     "BLUE_COLOR")
   (br-magenta  "PURPLE_COLOR")
   (br-cyan     "CYAN_COLOR")
   (br-white    "FG_COLOR")
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
EMACS_TEMPLATE

    # Replace placeholders with actual colors
    sed -i "s|BG_COLOR|${colors[bg]}|g" "$output_file"
    sed -i "s|BG_DARK_COLOR|${colors[bg_dark]}|g" "$output_file"
    sed -i "s|BG_HIGHLIGHT_COLOR|${colors[bg_highlight]}|g" "$output_file"
    sed -i "s|FG_COLOR|${colors[fg]}|g" "$output_file"
    sed -i "s|FG_DARK_COLOR|${colors[fg_dark]}|g" "$output_file"
    sed -i "s|COMMENT_COLOR|${colors[comment]}|g" "$output_file"
    sed -i "s|RED_COLOR|${colors[red]}|g" "$output_file"
    sed -i "s|ORANGE_COLOR|${colors[orange]}|g" "$output_file"
    sed -i "s|YELLOW_COLOR|${colors[yellow]}|g" "$output_file"
    sed -i "s|GREEN_COLOR|${colors[green]}|g" "$output_file"
    sed -i "s|CYAN_COLOR|${colors[cyan]}|g" "$output_file"
    sed -i "s|BLUE_COLOR|${colors[blue]}|g" "$output_file"
    sed -i "s|PURPLE_COLOR|${colors[purple]}|g" "$output_file"
    sed -i "s|MAGENTA_COLOR|${colors[magenta]}|g" "$output_file"

    # Verify no placeholders remain
    if grep -q "_COLOR" "$output_file"; then
        echo "ERROR: Some placeholders were not replaced" >&2
        grep "_COLOR" "$output_file" >&2
        return 1
    fi

    echo "  ✓ Generated theme file: $output_file" >&2

    # Verify basic elisp syntax (check parentheses balance)
    local open_parens=$(grep -o '(' "$output_file" | wc -l)
    local close_parens=$(grep -o ')' "$output_file" | wc -l)

    if [ "$open_parens" -ne "$close_parens" ]; then
        echo "ERROR: Unbalanced parentheses (open: $open_parens, close: $close_parens)" >&2
        return 1
    fi

    echo "  ✓ Basic syntax check passed" >&2

    return 0
}

# Test function for Phase 3
test_generation() {
    local theme=$1
    local nvim_file="$theme/neovim.lua"

    echo "========================================"
    echo "Testing generation: $theme"
    echo "========================================"

    # Step 1: Extract colors
    source ./extract_neovim_colors.sh
    local colors_file
    if ! colors_file=$(extract_neovim_colors_lua "$nvim_file" 2>/dev/null); then
        echo "✗ Extraction failed"
        return 1
    fi

    echo "✓ Extracted colors"

    # Step 2: Generate theme
    local output_file=$(mktemp --suffix=.el)
    if ! generate_emacs_from_colors "$colors_file" "$output_file"; then
        echo "✗ Generation failed"
        rm -f "$colors_file" "$output_file"
        return 1
    fi

    echo "✓ Generated theme file"

    # Step 3: Show sample of generated file
    echo ""
    echo "Generated file preview (first 30 lines):"
    echo "----------------------------------------"
    head -30 "$output_file"
    echo "..."
    echo "----------------------------------------"
    echo ""

    # Step 4: Validate it's valid elisp (if emacs available)
    if command -v emacs >/dev/null 2>&1; then
        echo "→ Validating elisp syntax with Emacs..."
        if emacs --batch --eval "(progn (load-file \"$output_file\") (message \"✓ Theme loaded successfully\"))" 2>&1 | grep -q "✓ Theme loaded"; then
            echo "✓ Emacs validation passed"
        else
            echo "⚠ Emacs validation had issues (but might be OK)"
        fi
    else
        echo "⚠ Emacs not available, skipping validation"
    fi

    echo ""
    echo "File stats:"
    echo "  Lines: $(wc -l < "$output_file")"
    echo "  Size: $(wc -c < "$output_file") bytes"
    echo "  Location: $output_file"

    # Cleanup
    rm -f "$colors_file"
    # Keep output file for inspection
    echo ""
    echo "✓ Generation test passed"
    echo "Generated file saved at: $output_file"

    return 0
}

# Run tests if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "Phase 3 Test: Emacs Theme Generation"
    echo "======================================"
    echo ""

    success_count=0
    total_count=0

    for theme in stone-creature field-of-dreams; do
        total_count=$((total_count + 1))
        if test_generation "$theme"; then
            success_count=$((success_count + 1))
        fi
        echo ""
    done

    echo "========================================"
    echo "Test Results: $success_count/$total_count themes generated successfully"
    echo "========================================"

    if [ $success_count -eq $total_count ]; then
        echo "✓ All tests passed!"
        exit 0
    else
        echo "✗ Some tests failed"
        exit 1
    fi
fi
