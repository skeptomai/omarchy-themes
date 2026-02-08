#!/bin/bash
# Test harness for integrated hook

test_hook_with_theme() {
    local theme_name="$1"
    local theme_path="$(pwd)/$theme_name"

    echo "========================================"
    echo "Testing integrated hook: $theme_name"
    echo "========================================"

    # Create mock theme directory
    local mock_theme=$(mktemp -d)
    echo "Mock theme dir: $mock_theme"

    # Copy theme files
    cp "$theme_path/neovim.lua" "$mock_theme/" 2>/dev/null || true
    cp "$theme_path/emacs.el" "$mock_theme/" 2>/dev/null || true
    cp "$theme_path/colors.toml" "$mock_theme/" 2>/dev/null || true

    # Set up environment to simulate hook
    export HOME_BACKUP="$HOME"

    # Create mock directory structure
    mkdir -p "$mock_theme/../current/theme"
    ln -sf "$mock_theme"/* "$mock_theme/../current/theme/" 2>/dev/null

    # Mock the helper functions
    success() { echo "✓ SUCCESS: $1"; }
    skipped() { echo "⊘ SKIPPED: $1"; }
    export -f success skipped

    # Test with neovim.lua (remove emacs.el if exists)
    echo ""
    echo "Test 1: neovim.lua conversion (Tier 2)"
    echo "----------------------------------------"
    rm -f "$mock_theme/emacs.el"

    # Run hook with mocked environment
    local output_file="$mock_theme/omarchy-doom-theme.el"
    (
        theme_dir="$mock_theme"
        emacs_output="$output_file"
        custom_emacs="$mock_theme/emacs.el"
        neovim_lua="$mock_theme/neovim.lua"

        source ./integrated_hook.sh 2>&1 | head -20
    )

    if [ -f "$output_file" ]; then
        echo "✓ Generated theme file"
        echo "  Size: $(wc -c < "$output_file") bytes"
        echo "  Lines: $(wc -l < "$output_file")"

        # Verify it contains expected colors
        if grep -q "autothemer-deftheme" "$output_file"; then
            echo "✓ Valid theme structure"
        else
            echo "✗ Invalid theme structure"
        fi

        # Show first few color definitions
        echo "  Sample colors:"
        grep -E '^\s*\([a-z-]+ "#[0-9a-fA-F]{6}"\)' "$output_file" | head -5 | sed 's/^/    /'
    else
        echo "✗ No theme file generated"
    fi

    # Test with explicit emacs.el (should use it directly)
    if [ -f "$theme_path/emacs.el" ]; then
        echo ""
        echo "Test 2: Explicit emacs.el (Tier 1)"
        echo "----------------------------------------"
        cp "$theme_path/emacs.el" "$mock_theme/"
        rm -f "$output_file"

        (
            theme_dir="$mock_theme"
            emacs_output="$output_file"
            custom_emacs="$mock_theme/emacs.el"
            neovim_lua="$mock_theme/neovim.lua"

            source ./integrated_hook.sh 2>&1 | head -10
        )

        if [ -f "$output_file" ]; then
            if diff -q "$theme_path/emacs.el" "$output_file" >/dev/null; then
                echo "✓ Used explicit emacs.el (files match)"
            else
                echo "⚠ Used emacs.el but files differ"
            fi
        else
            echo "✗ No theme file generated"
        fi
    fi

    # Cleanup
    rm -rf "$mock_theme"

    echo ""
    return 0
}

# Main test
echo "Integrated Hook Test Suite"
echo "======================================"
echo ""

chmod +x ./integrated_hook.sh

for theme in stone-creature field-of-dreams; do
    test_hook_with_theme "$theme"
    echo ""
done

echo "======================================"
echo "Tests complete"
echo "======================================"
