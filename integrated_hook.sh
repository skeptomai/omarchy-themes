#!/bin/bash
# Integrated 20-emacs.sh Hook
# Three-tier fallback: emacs.el → neovim.lua → colors.toml

# Use environment variables if set, otherwise use defaults
theme_dir="${theme_dir:-$HOME/.config/omarchy/current/theme}"
emacs_output="${emacs_output:-$theme_dir/omarchy-doom-theme.el}"
custom_emacs="${custom_emacs:-$theme_dir/emacs.el}"
neovim_lua="${neovim_lua:-$theme_dir/neovim.lua}"

# Helper functions for theme-set system reporting
success() {
    echo "✓ $1" >&2
}

skipped() {
    echo "⊘ Skipped: $1" >&2
}

# Source extraction and generation functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Inline extraction function (simplified from extract_neovim_colors.sh)
extract_colors_with_lua() {
    # All variables local to avoid pollution
    nvim_file="$1"
    temp_output=$(mktemp)
    temp_script=$(mktemp --suffix=.lua)

    # Determine Lua interpreter
    lua_cmd=""
    if command -v nvim >/dev/null 2>&1; then
        lua_cmd="nvim"
    elif command -v luajit >/dev/null 2>&1; then
        lua_cmd="luajit"
    elif command -v lua >/dev/null 2>&1; then
        lua_cmd="lua"
    else
        rm -f "$temp_output" "$temp_script"
        return 1
    fi

    # Create Lua extraction script
    cat > "$temp_script" << 'LUA_SCRIPT'
local nvim_file = arg[1]
io.stderr:write("-- Loading config file: " .. nvim_file .. "\n")
local success, config = pcall(dofile, nvim_file)
if not success then
    io.stderr:write("ERROR: Failed to load config file: " .. tostring(config) .. "\n")
    os.exit(1)
end

local function find_colors(tbl, depth)
    depth = depth or 0
    if depth > 10 or type(tbl) ~= "table" then return nil end
    if tbl.colors and type(tbl.colors) == "table" then return tbl.colors end
    if tbl.opts and type(tbl.opts) == "table" and tbl.opts.colors then return tbl.opts.colors end
    for i = 1, #tbl do
        if type(tbl[i]) == "table" then
            local found = find_colors(tbl[i], depth + 1)
            if found then return found end
        end
    end
    return nil
end

local colors = find_colors(config)
if not colors then
    io.stderr:write("ERROR: Could not find colors table\n")
    os.exit(1)
end

local extracted = 0
for key, value in pairs(colors) do
    if type(value) == "string" and value:match("^#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
        io.stdout:write(key .. "=" .. value .. "\n")
        extracted = extracted + 1
    end
end

if extracted < 10 then
    io.stderr:write("ERROR: Too few colors: " .. extracted .. "\n")
    os.exit(1)
end
LUA_SCRIPT

    # Execute (capture only color output)
    if [ "$lua_cmd" = "nvim" ]; then
        nvim -l "$temp_script" "$nvim_file" > "$temp_output" 2>/dev/null
    else
        $lua_cmd "$temp_script" "$nvim_file" > "$temp_output" 2>/dev/null
    fi

    exit_code=$?
    rm -f "$temp_script"

    if [ $exit_code -ne 0 ]; then
        rm -f "$temp_output"
        return 1
    fi

    # Extract color lines only
    colors_only=$(mktemp)
    grep -E "^[a-z_]+=#[0-9a-fA-F]{6}$" "$temp_output" > "$colors_only"
    rm -f "$temp_output"

    if [ ! -s "$colors_only" ]; then
        rm -f "$colors_only"
        return 1
    fi

    # Output ONLY the file path to stdout
    echo "$colors_only"
    return 0
}

# Inline generation function (simplified from generate_emacs_theme.sh)
generate_emacs_theme() {
    colors_file="$1"
    output_file="$2"

    # Read colors into array
    declare -A colors
    while IFS='=' read -r key value; do
        colors[$key]="$value"
    done < "$colors_file"

    # Set defaults for optional colors
    colors[bg_dark]="${colors[bg_dark]:-${colors[bg]}}"
    colors[bg_highlight]="${colors[bg_highlight]:-${colors[bg]}}"
    colors[fg_dark]="${colors[fg_dark]:-${colors[fg]}}"

    cat > "$output_file" << 'TEMPLATE'
;; Generated from neovim.lua by omarchy-emacs-themer
(autothemer-deftheme
 omarchy-doom "Omarchy theme generated from neovim.lua"
 ((((class color) (min-colors #xFFFFFF)))
   (bg "BG") (bg-dark "BGD") (bg-highlight "BGH")
   (fg "FG") (fg-dark "FGD") (comment "COM")
   (red "RED") (orange "ORA") (yellow "YEL") (green "GRE")
   (cyan "CYA") (blue "BLU") (purple "PUR") (magenta "MAG")
   (cursor-fg "BG") (cursor-bg "FG") (sel-fg "BG") (sel-bg "BLU")
   (black "BG") (white "FG") (br-black "COM") (br-red "ORA")
   (br-green "GRE") (br-yellow "YEL") (br-blue "BLU")
   (br-magenta "PUR") (br-cyan "CYA") (br-white "FG"))
 ((default (:foreground fg :background bg))
  (cursor (:foreground cursor-fg :background cursor-bg))
  (region (:foreground sel-fg :background sel-bg))
  (highlight (:background sel-bg))
  (shadow (:foreground comment))
  (minibuffer-prompt (:foreground blue :bold t))
  (link (:foreground blue :underline t))
  (link-visited (:foreground magenta :underline t))
  (line-number (:foreground comment))
  (line-number-current-line (:foreground orange))
  (isearch (:foreground bg :background yellow))
  (lazy-highlight (:foreground bg :background br-yellow))
  (match (:foreground bg :background blue))
  (font-lock-keyword-face (:foreground purple))
  (font-lock-function-name-face (:foreground blue))
  (font-lock-function-call-face (:foreground blue))
  (font-lock-variable-name-face (:foreground red))
  (font-lock-variable-use-face (:foreground red))
  (font-lock-string-face (:foreground green))
  (font-lock-doc-face (:foreground green :italic t))
  (font-lock-comment-face (:foreground comment :italic t))
  (font-lock-comment-delimiter-face (:foreground comment :italic t))
  (font-lock-constant-face (:foreground orange))
  (font-lock-number-face (:foreground orange))
  (font-lock-type-face (:foreground yellow))
  (font-lock-builtin-face (:foreground cyan))
  (font-lock-preprocessor-face (:foreground cyan))
  (font-lock-negation-char-face (:foreground red))
  (font-lock-warning-face (:foreground yellow :bold t))
  (font-lock-regexp-grouping-construct (:foreground cyan))
  (font-lock-regexp-grouping-backslash (:foreground cyan))
  (mode-line (:foreground fg :background bg-dark))
  (mode-line-inactive (:foreground comment :background bg-dark))
  (mode-line-emphasis (:foreground blue :bold t))
  (mode-line-buffer-id (:foreground fg :bold t))
  (error (:foreground red))
  (warning (:foreground yellow))
  (success (:foreground green))
  (diff-added (:foreground green))
  (diff-removed (:foreground red))
  (diff-changed (:foreground magenta))
  (diff-header (:foreground blue :bold t))
  (show-paren-match (:foreground bg :background blue :bold t))
  (show-paren-mismatch (:foreground bg :background red :bold t))
  (trailing-whitespace (:background red))
  (fringe (:foreground comment :background bg))
  (vertical-border (:foreground bg-dark))))
(provide-theme 'omarchy-doom)
TEMPLATE

    # Replace placeholders
    sed -i "s|BG\"|${colors[bg]}\"|g; s|BGD\"|${colors[bg_dark]}\"|g; s|BGH\"|${colors[bg_highlight]}\"|g" "$output_file"
    sed -i "s|FG\"|${colors[fg]}\"|g; s|FGD\"|${colors[fg_dark]}\"|g; s|COM\"|${colors[comment]}\"|g" "$output_file"
    sed -i "s|RED\"|${colors[red]}\"|g; s|ORA\"|${colors[orange]}\"|g; s|YEL\"|${colors[yellow]}\"|g" "$output_file"
    sed -i "s|GRE\"|${colors[green]}\"|g; s|CYA\"|${colors[cyan]}\"|g" "$output_file"
    sed -i "s|BLU\"|${colors[blue]}\"|g; s|PUR\"|${colors[purple]}\"|g; s|MAG\"|${colors[magenta]}\"|g" "$output_file"

    return 0
}

# Original ANSI generation function (fallback)
create_dynamic_theme() {
    cat > "$emacs_output" << EOF
(autothemer-deftheme
 omarchy-doom "A theme for Omarchy Linux"
 ((((class color) (min-colors #xFFFFFF)))
   (bg "#${primary_background}") (fg "#${primary_foreground}")
   (cursor-fg "#${primary_background}") (cursor-bg "#${cursor_color}")
   (sel-fg "#${selection_foreground}") (sel-bg "#${selection_background}")
   (black "#${normal_black}") (red "#${normal_red}") (green "#${normal_green}")
   (yellow "#${normal_yellow}") (blue "#${normal_blue}") (magenta "#${normal_magenta}")
   (cyan "#${normal_cyan}") (white "#${normal_white}")
   (br-black "#${bright_black}") (br-red "#${bright_red}") (br-green "#${bright_green}")
   (br-yellow "#${bright_yellow}") (br-blue "#${bright_blue}") (br-magenta "#${bright_magenta}")
   (br-cyan "#${bright_cyan}") (br-white "#${bright_white}"))
 ((default (:foreground fg :background bg))
  (cursor (:foreground cursor-fg :background cursor-bg))
  (region (:foreground sel-fg :background sel-bg))
  (highlight (:background sel-bg))
  (shadow (:foreground br-black))
  (minibuffer-prompt (:foreground blue :bold t))
  (link (:foreground blue :underline t))
  (link-visited (:foreground magenta :underline t))
  (line-number (:foreground br-black))
  (line-number-current-line (:foreground br-red))
  (isearch (:foreground bg :background yellow))
  (lazy-highlight (:foreground bg :background br-yellow))
  (match (:foreground bg :background blue))
  (font-lock-keyword-face (:foreground magenta))
  (font-lock-function-name-face (:foreground blue))
  (font-lock-function-call-face (:foreground blue))
  (font-lock-variable-name-face (:foreground red))
  (font-lock-variable-use-face (:foreground red))
  (font-lock-string-face (:foreground green))
  (font-lock-doc-face (:foreground green :italic t))
  (font-lock-comment-face (:foreground br-black :italic t))
  (font-lock-comment-delimiter-face (:foreground br-black :italic t))
  (font-lock-constant-face (:foreground br-red))
  (font-lock-number-face (:foreground br-red))
  (font-lock-type-face (:foreground yellow))
  (font-lock-builtin-face (:foreground cyan))
  (font-lock-preprocessor-face (:foreground cyan))
  (font-lock-negation-char-face (:foreground red))
  (font-lock-warning-face (:foreground yellow :bold t))
  (font-lock-regexp-grouping-construct (:foreground cyan))
  (font-lock-regexp-grouping-backslash (:foreground cyan))
  (mode-line (:foreground fg :background black))
  (mode-line-inactive (:foreground br-black :background black))
  (mode-line-emphasis (:foreground blue :bold t))
  (mode-line-buffer-id (:foreground fg :bold t))
  (error (:foreground red))
  (warning (:foreground yellow))
  (success (:foreground green))
  (diff-added (:foreground green))
  (diff-removed (:foreground red))
  (diff-changed (:foreground magenta))
  (diff-header (:foreground blue :bold t))
  (show-paren-match (:foreground bg :background blue :bold t))
  (show-paren-mismatch (:foreground bg :background red :bold t))
  (trailing-whitespace (:background red))
  (fringe (:foreground br-black :background bg))
  (vertical-border (:foreground black))))
(provide-theme 'omarchy-doom)
EOF
}

# Main hook logic
main() {
    if ! command -v emacs >/dev/null 2>&1; then
        skipped "Emacs"
        exit 0
    fi

    # === TIER 1: Explicit emacs.el ===
    if [ -f "$custom_emacs" ]; then
        echo "✓ Using explicit emacs.el"
        cp "$custom_emacs" "$emacs_output"
        emacsclient -e "(omarchy-themer-install-and-load \"$emacs_output\")" 2>/dev/null || true
        success "Emacs theme updated (explicit)"
        exit 0
    fi

    # === TIER 2: Convert from neovim.lua ===
    if [ -f "$neovim_lua" ]; then
        echo "→ Found neovim.lua, attempting conversion"

        colors_file=$(extract_colors_with_lua "$neovim_lua")
        if [ -n "$colors_file" ] && [ -f "$colors_file" ]; then
            echo "✓ Extracted colors using Lua"

            if generate_emacs_theme "$colors_file" "$emacs_output" 2>/dev/null; then
                echo "✓ Generated emacs theme from neovim.lua"
                rm -f "$colors_file"
                emacsclient -e "(omarchy-themer-install-and-load \"$emacs_output\")" 2>/dev/null || true
                success "Emacs theme updated (from neovim.lua)"
                exit 0
            else
                echo "⚠ Generation failed"
            fi

            rm -f "$colors_file"
        else
            echo "⚠ Lua extraction failed"
        fi

        echo "→ Falling back to colors.toml"
    fi

    # === TIER 3: Fall back to colors.toml (ANSI mapping) ===
    echo "→ Generating from colors.toml (ANSI mapping)"
    create_dynamic_theme
    emacsclient -e "(omarchy-themer-install-and-load \"$emacs_output\")" 2>/dev/null || true
    success "Emacs theme updated (ANSI fallback)"
    exit 0
}

# Only run main if script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
