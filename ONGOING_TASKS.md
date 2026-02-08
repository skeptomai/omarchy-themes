# Ongoing Tasks - Omarchy Themes

## Current Task: Dynamic neovim.lua → emacs.el Conversion

### Goal
Implement three-tier fallback system for Emacs theming:
1. Check for explicit `emacs.el` → use it
2. Check for `neovim.lua` → convert to emacs.el dynamically
3. Fall back to `colors.toml` → generate from ANSI colors

### Context
We want prescriptive Emacs theming (like neovim.lua) but don't want to maintain both files. Solution: parse neovim.lua and generate emacs.el on-the-fly with robust error handling.

---

## Parsing Strategy Analysis

### The Challenge

The neovim.lua files are **valid Lua code**, not simple config files:
```lua
return {
    {
        opts = {
            colors = {
                bg = "#d8d5cd",
                red = "#d20f39",
                -- Comments and nested structure
            },
        },
    },
}
```

### Parsing Approaches Considered

#### Option A: Use Lua Interpreter
```bash
lua -e "dofile('neovim.lua'); print(colors.red)"
```
**Pros:** Proper parsing, handles all Lua syntax
**Cons:** Requires lua binary
**Risk:** Medium if lua not installed, but we can detect and fall back
**Security:** Low risk - we trust our own theme files

#### Option B: Regex Pattern Matching
```bash
grep -oP 'red\s*=\s*"#[0-9a-fA-F]{6}"' neovim.lua
```
**Pros:** No dependencies, fast
**Cons:** Fragile, breaks with format changes
**Risk:** Medium - could extract wrong values

#### Option C: AWK State Machine
```bash
awk '/colors = {/,/}/ { if ($1 ~ /^[a-z_]+$/) print $1, $3 }'
```
**Pros:** More robust than regex, structured, no dependencies
**Cons:** Complex, still pattern-dependent
**Risk:** Low-Medium with proper validation

---

## Selected Approach: Hybrid Three-Tier Parsing

### Tier 1: Lua Interpreter (Preferred)
- **When:** lua or luajit binary is available
- **Method:** Execute neovim.lua and extract colors table
- **Pros:** Handles all Lua syntax, most reliable
- **Cons:** Requires lua installation
- **Fallback:** If lua not found OR execution fails → Tier 2

### Tier 2: AWK Pattern Matching (Robust Fallback)
- **When:** Lua interpreter unavailable or fails
- **Method:** Extract colors with strict AWK patterns
- **Pros:** No dependencies, reliable for our format
- **Cons:** Could break with major format changes
- **Fallback:** If extraction/validation fails → Tier 3

### Tier 3: colors.toml ANSI Mapping (Safe Fallback)
- **When:** Both Lua and AWK methods fail
- **Method:** Existing implementation (generate from ANSI colors)
- **Pros:** Always works, existing code
- **Cons:** Less control than neovim.lua-based generation

---

## Implementation Plan

### Phase 1: Lua Interpreter Extraction

```bash
extract_neovim_colors_lua() {
    local nvim_file="$1"
    local temp_output=$(mktemp)

    # Check if lua interpreter exists
    if ! command -v lua >/dev/null 2>&1 && ! command -v luajit >/dev/null 2>&1; then
        echo "INFO: Lua interpreter not found, will try AWK method"
        return 1
    fi

    local lua_cmd="lua"
    command -v luajit >/dev/null 2>&1 && lua_cmd="luajit"

    # Execute Lua to extract colors
    $lua_cmd << EOF > "$temp_output" 2>&1
local config = dofile("$nvim_file")

-- Navigate the config structure
local colors = nil
if config[1] and config[1].opts and config[1].opts.colors then
    colors = config[1].opts.colors
end

if not colors then
    print("ERROR: Could not find colors table")
    os.exit(1)
end

-- Required colors
local required = {
    "bg", "fg", "red", "orange", "yellow",
    "green", "cyan", "blue", "purple", "magenta",
    "comment", "bg_dark", "bg_highlight", "fg_dark"
}

-- Validate and print colors
local found = 0
for _, key in ipairs(required) do
    if colors[key] then
        local value = colors[key]
        -- Validate hex format
        if type(value) == "string" and value:match("^#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
            print(key .. "=" .. value)
            found = found + 1
        end
    end
end

if found < 10 then
    print("ERROR: Too few valid colors found: " .. found)
    os.exit(1)
end
EOF

    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        echo "ERROR: Lua extraction failed"
        rm -f "$temp_output"
        return 1
    fi

    # Check output is valid
    if grep -q "^ERROR:" "$temp_output"; then
        cat "$temp_output" >&2
        rm -f "$temp_output"
        return 1
    fi

    echo "$temp_output"
    return 0
}
```

### Phase 2: AWK Fallback Extraction

```bash
extract_neovim_colors_awk() {
    local nvim_file="$1"
    local temp_colors=$(mktemp)

    # Extract colors block with strict awk
    awk '
        /colors = \{/ { in_colors=1; next }
        in_colors && /^\s*\}/ { in_colors=0 }
        in_colors && /[a-z_]+[[:space:]]*=[[:space:]]*"#[0-9a-fA-F]{6}"/ {
            # Extract: colorname = "#hexcode"
            match($0, /([a-z_]+)[[:space:]]*=[[:space:]]*"(#[0-9a-fA-F]{6})"/, arr)
            if (arr[1] && arr[2]) {
                print arr[1] "=" arr[2]
            }
        }
    ' "$nvim_file" > "$temp_colors"

    # Validate output
    if [ ! -s "$temp_colors" ]; then
        echo "ERROR: AWK extraction produced no output"
        rm -f "$temp_colors"
        return 1
    fi

    echo "$temp_colors"
    return 0
}
```

### Phase 3: Validation (Common for Both Methods)

```bash
validate_extracted_colors() {
    local colors_file="$1"

    # Required colors for Emacs theme
    local required_colors=(
        "bg" "fg" "red" "orange" "yellow"
        "green" "cyan" "blue" "purple" "magenta"
        "comment"
    )

    # Check file is not empty
    if [ ! -s "$colors_file" ]; then
        echo "ERROR: No colors extracted"
        return 1
    fi

    # Count extracted colors
    local count=$(wc -l < "$colors_file")
    if [ "$count" -lt 10 ]; then
        echo "ERROR: Too few colors extracted ($count < 10)"
        return 1
    fi

    # Verify each required color exists
    for color in "${required_colors[@]}"; do
        if ! grep -q "^${color}=" "$colors_file"; then
            echo "WARNING: Required color '$color' not found"
            # Don't fail - some colors might be optional
        fi
    done

    # Validate hex format for each color
    local invalid=0
    while IFS='=' read -r name value; do
        if ! [[ "$value" =~ ^#[0-9a-fA-F]{6}$ ]]; then
            echo "ERROR: Invalid hex format for $name: $value"
            invalid=1
        fi
    done < "$colors_file"

    if [ $invalid -eq 1 ]; then
        return 1
    fi

    return 0
}
```

### Phase 4: Generate Emacs Theme

```bash
generate_emacs_from_neovim() {
    local colors_file="$1"
    local output_file="$2"

    # Read colors into associative array
    declare -A colors
    while IFS='=' read -r name value; do
        colors[$name]="$value"
    done < "$colors_file"

    # Set defaults for optional colors
    colors[bg_dark]="${colors[bg_dark]:-${colors[bg]}}"
    colors[bg_highlight]="${colors[bg_highlight]:-${colors[bg]}}"
    colors[fg_dark]="${colors[fg_dark]:-${colors[fg]}}"

    # Generate complete emacs.el
    cat > "$output_file" << 'EMACS_EOF'
;; Generated from neovim.lua
(autothemer-deftheme
 omarchy-doom "Omarchy theme generated from neovim.lua"
 ((((class color) (min-colors #xFFFFFF)))

   ;; Color palette (from neovim.lua)
   (bg          "REPLACE_BG")
   (bg-dark     "REPLACE_BG_DARK")
   (bg-highlight "REPLACE_BG_HIGHLIGHT")
   (fg          "REPLACE_FG")
   (fg-dark     "REPLACE_FG_DARK")
   (comment     "REPLACE_COMMENT")

   ;; Syntax colors
   (red         "REPLACE_RED")
   (orange      "REPLACE_ORANGE")
   (yellow      "REPLACE_YELLOW")
   (green       "REPLACE_GREEN")
   (cyan        "REPLACE_CYAN")
   (blue        "REPLACE_BLUE")
   (purple      "REPLACE_PURPLE")
   (magenta     "REPLACE_MAGENTA")

   ;; Cursor and selection
   (cursor-fg   "REPLACE_BG")
   (cursor-bg   "REPLACE_FG")
   (sel-fg      "REPLACE_BG")
   (sel-bg      "REPLACE_BLUE")

   ;; ANSI colors (for compatibility)
   (black       "REPLACE_BG")
   (white       "REPLACE_FG")
   (br-black    "REPLACE_COMMENT")
   (br-red      "REPLACE_ORANGE")
   (br-green    "REPLACE_GREEN")
   (br-yellow   "REPLACE_YELLOW")
   (br-blue     "REPLACE_BLUE")
   (br-magenta  "REPLACE_PURPLE")
   (br-cyan     "REPLACE_CYAN")
   (br-white    "REPLACE_FG")
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
EMACS_EOF

    # Replace placeholders with actual colors
    for key in "${!colors[@]}"; do
        local upper_key=$(echo "$key" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
        sed -i "s|REPLACE_${upper_key}|${colors[$key]}|g" "$output_file"
    done

    # Verify no placeholders remain
    if grep -q "REPLACE_" "$output_file"; then
        echo "ERROR: Some colors were not replaced in generated theme"
        return 1
    fi

    return 0
}
```

### Phase 5: Complete Hook Integration

```bash
#!/bin/bash

theme_dir="$HOME/.config/omarchy/current/theme"
emacs_output="$theme_dir/omarchy-doom-theme.el"
custom_emacs="$theme_dir/emacs.el"
neovim_lua="$theme_dir/neovim.lua"

# === TIER 1: Explicit emacs.el ===
if [ -f "$custom_emacs" ]; then
    echo "✓ Using explicit emacs.el"
    cp "$custom_emacs" "$emacs_output"
    emacsclient -e "(omarchy-themer-install-and-load \"$emacs_output\")"
    success "Emacs theme updated (explicit)"
    exit 0
fi

# === TIER 2: Convert from neovim.lua ===
if [ -f "$neovim_lua" ]; then
    echo "→ Found neovim.lua, attempting conversion to emacs theme"

    colors_file=""
    extraction_method=""

    # Try Lua interpreter first
    if colors_file=$(extract_neovim_colors_lua "$neovim_lua" 2>&1); then
        extraction_method="lua"
        echo "✓ Extracted colors using Lua interpreter"
    # Fall back to AWK
    elif colors_file=$(extract_neovim_colors_awk "$neovim_lua" 2>&1); then
        extraction_method="awk"
        echo "✓ Extracted colors using AWK"
    else
        echo "⚠ Both Lua and AWK extraction failed, falling back to colors.toml"
        colors_file=""
    fi

    # If we extracted colors, validate and generate
    if [ -n "$colors_file" ] && [ -f "$colors_file" ]; then
        if validate_extracted_colors "$colors_file"; then
            echo "✓ Validated extracted colors"

            if generate_emacs_from_neovim "$colors_file" "$emacs_output"; then
                echo "✓ Generated emacs theme from neovim.lua (method: $extraction_method)"
                rm -f "$colors_file"
                emacsclient -e "(omarchy-themer-install-and-load \"$emacs_output\")"
                success "Emacs theme updated (from neovim.lua)"
                exit 0
            else
                echo "⚠ Failed to generate emacs theme"
            fi
        else
            echo "⚠ Validation failed for extracted colors"
        fi

        rm -f "$colors_file"
    fi

    echo "→ Falling back to colors.toml"
fi

# === TIER 3: Fall back to colors.toml (ANSI mapping) ===
echo "→ Generating from colors.toml (ANSI mapping)"
if ! command -v emacs >/dev/null 2>&1; then
    skipped "Emacs"
fi

create_dynamic_theme
emacsclient -e "(omarchy-themer-install-and-load \"$emacs_output\")"
success "Emacs theme updated (ANSI fallback)"
exit 0
```

---

## Error Boundaries & Safety

### Error Detection Points
1. Lua interpreter not found → try AWK
2. Lua execution fails → try AWK
3. AWK extraction produces no output → fall back to colors.toml
4. Validation fails (bad hex, missing colors) → fall back to colors.toml
5. Generation fails (sed errors, file write) → fall back to colors.toml
6. All methods fail → keep existing theme, log error

### Safety Guarantees
- ✅ Never leaves Emacs without a theme
- ✅ Never overwrites existing theme until new one is validated
- ✅ Always falls back to known-working method
- ✅ Clear logging at each step
- ✅ Temp files cleaned up even on failure

---

## Testing Strategy

### Test Cases
1. **Both lua and luajit available** → should use lua
2. **Only lua available** → should use lua
3. **No lua available** → should use AWK
4. **Corrupted neovim.lua** (bad syntax) → lua fails, AWK succeeds or fails to colors.toml
5. **Missing colors in neovim.lua** → validation catches, falls back
6. **Invalid hex codes** → validation catches, falls back
7. **No neovim.lua** → directly to colors.toml
8. **Explicit emacs.el exists** → should bypass all conversion

### Test Procedure
1. Backup current hooks
2. Install new hook
3. Test each scenario above
4. Verify Emacs theme loads correctly
5. Verify fallbacks work
6. Check for any errors in logs

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Lua not installed | Medium | Low | AWK fallback |
| AWK extraction fails | Low | Low | colors.toml fallback |
| Bad generated elisp | Low | Medium | Validate before use, test in batch mode? |
| File system errors | Very Low | Medium | Check writes, trap errors |
| Theme corruption | Very Low | High | Never overwrite until validated |

---

## Open Questions

1. **Should we cache generated emacs.el?**
   - Pro: Faster theme switches, less computation
   - Con: Could become stale if neovim.lua updated
   - Decision: NO - always regenerate for consistency

2. **Should we validate generated elisp syntax?**
   - Pro: Catch generation errors before Emacs sees them
   - Con: Requires `emacs --batch`, adds overhead
   - Decision: TBD - test performance impact

3. **Log verbosity and location?**
   - Current: Echo to terminal during theme-set
   - Alternative: Log to ~/.config/omarchy/logs/theme-hook.log
   - Decision: TBD - check if hook output is visible to user

4. **Should we support other Lua config formats?**
   - Current: Only supports our specific neovim.lua structure
   - Future: Could support flatter formats
   - Decision: NO for now - YAGNI

---

## Implementation Phases

### Phase 1: Lua Interpreter Extraction (NEXT)
- [ ] Implement `extract_neovim_colors_lua()`
- [ ] Test with both lua and luajit
- [ ] Test with both existing neovim.lua files
- [ ] Test error handling (missing lua, bad syntax)

### Phase 2: AWK Fallback
- [ ] Implement `extract_neovim_colors_awk()`
- [ ] Test with existing files
- [ ] Test with edge cases

### Phase 3: Validation & Generation
- [ ] Implement `validate_extracted_colors()`
- [ ] Implement `generate_emacs_from_neovim()`
- [ ] Test generated elisp loads in Emacs

### Phase 4: Hook Integration
- [ ] Update 20-emacs.sh with three-tier logic
- [ ] Test all fallback paths
- [ ] Test with both themes

### Phase 5: Deployment
- [ ] Final testing
- [ ] Update documentation
- [ ] Deploy to system hooks
- [ ] Commit and push to git

---

## Current Status

**Status:** Planning complete, ready for Phase 1 implementation

**Next Steps:**
1. Implement Lua extraction function
2. Test with existing themes
3. Verify error handling
4. Move to Phase 2

**Notes:**
- Hybrid approach gives us reliability with graceful degradation
- Three tiers ensure we always have a working theme
- Heavy validation prevents bad themes from reaching Emacs
