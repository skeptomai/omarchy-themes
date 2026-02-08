#!/bin/bash
# Comprehensive test suite for color extraction

source ./extract_neovim_colors.sh

# Test 1: Extract colors and compare with source file
test_color_correctness() {
    local theme=$1
    local nvim_file="$theme/neovim.lua"

    echo "Testing: $theme"
    echo "================================"

    # Extract colors using our function
    local colors_file
    if ! colors_file=$(extract_neovim_colors_lua "$nvim_file" 2>/dev/null); then
        echo "✗ Extraction failed"
        return 1
    fi

    echo "✓ Extraction succeeded"

    # Read the neovim.lua file and extract expected colors manually
    local expected_colors=$(grep -oP '(bg|fg|red|orange|yellow|green|cyan|blue|purple|magenta|comment|bg_dark|bg_highlight|fg_dark)\s*=\s*"#[0-9a-fA-F]{6}"' "$nvim_file" | sed 's/\s*=\s*/=/g' | sed 's/"//g' | sort)

    # Read extracted colors
    local extracted_colors=$(sort "$colors_file")

    # Count colors
    local expected_count=$(echo "$expected_colors" | wc -l)
    local extracted_count=$(echo "$extracted_colors" | wc -l)

    echo "  Expected colors: $expected_count"
    echo "  Extracted colors: $extracted_count"

    # Compare each color
    local all_match=true
    while IFS='=' read -r key expected_value; do
        local extracted_value=$(grep "^${key}=" "$colors_file" | cut -d'=' -f2)

        if [ "$extracted_value" = "$expected_value" ]; then
            echo "  ✓ $key: $expected_value"
        else
            echo "  ✗ $key: expected $expected_value, got $extracted_value"
            all_match=false
        fi
    done <<< "$expected_colors"

    # Check for extra colors extracted
    while IFS='=' read -r key value; do
        if ! echo "$expected_colors" | grep -q "^${key}="; then
            echo "  ℹ Extra color: $key=$value"
        fi
    done <<< "$extracted_colors"

    rm -f "$colors_file"

    if [ "$all_match" = true ] && [ "$extracted_count" -ge "$expected_count" ]; then
        echo "✓ All colors match and are correct"
        return 0
    else
        echo "✗ Color mismatch detected"
        return 1
    fi
}

# Test 2: Validate hex format
test_hex_format() {
    local theme=$1
    local nvim_file="$theme/neovim.lua"

    echo ""
    echo "Testing hex format: $theme"
    echo "================================"

    local colors_file
    if ! colors_file=$(extract_neovim_colors_lua "$nvim_file" 2>/dev/null); then
        echo "✗ Extraction failed"
        return 1
    fi

    local invalid=0
    while IFS='=' read -r key value; do
        # Check format: #RRGGBB
        if [[ ! "$value" =~ ^#[0-9a-fA-F]{6}$ ]]; then
            echo "  ✗ Invalid hex: $key=$value"
            invalid=$((invalid + 1))
        fi
    done < "$colors_file"

    rm -f "$colors_file"

    if [ $invalid -eq 0 ]; then
        echo "✓ All hex values are valid"
        return 0
    else
        echo "✗ Found $invalid invalid hex values"
        return 1
    fi
}

# Test 3: Required colors present
test_required_colors() {
    local theme=$1
    local nvim_file="$theme/neovim.lua"

    echo ""
    echo "Testing required colors: $theme"
    echo "================================"

    local colors_file
    if ! colors_file=$(extract_neovim_colors_lua "$nvim_file" 2>/dev/null); then
        echo "✗ Extraction failed"
        return 1
    fi

    local required=(bg fg red orange yellow green cyan blue purple magenta comment)
    local missing=0

    for color in "${required[@]}"; do
        if grep -q "^${color}=" "$colors_file"; then
            echo "  ✓ $color present"
        else
            echo "  ✗ $color missing"
            missing=$((missing + 1))
        fi
    done

    rm -f "$colors_file"

    if [ $missing -eq 0 ]; then
        echo "✓ All required colors present"
        return 0
    else
        echo "✗ Missing $missing required colors"
        return 1
    fi
}

# Test 4: Error handling with bad file
test_error_handling() {
    echo ""
    echo "Testing error handling"
    echo "================================"

    # Test with non-existent file
    local result
    if result=$(extract_neovim_colors_lua "/tmp/nonexistent.lua" 2>&1); then
        echo "✗ Should have failed with non-existent file"
        rm -f "$result" 2>/dev/null
        return 1
    else
        echo "✓ Correctly failed with non-existent file"
    fi

    # Test with invalid Lua file
    local bad_file=$(mktemp --suffix=.lua)
    echo "this is not valid lua!!!" > "$bad_file"

    if result=$(extract_neovim_colors_lua "$bad_file" 2>&1); then
        echo "✗ Should have failed with invalid Lua"
        rm -f "$result" "$bad_file"
        return 1
    else
        echo "✓ Correctly failed with invalid Lua"
    fi

    rm -f "$bad_file"

    # Test with Lua file that has no colors
    local no_colors=$(mktemp --suffix=.lua)
    echo "return { foo = 'bar' }" > "$no_colors"

    if result=$(extract_neovim_colors_lua "$no_colors" 2>&1); then
        echo "✗ Should have failed with no colors table"
        rm -f "$result" "$no_colors"
        return 1
    else
        echo "✓ Correctly failed with no colors table"
    fi

    rm -f "$no_colors"

    echo "✓ All error cases handled correctly"
    return 0
}

# Test 5: Compare with manually verified values
test_known_values() {
    echo ""
    echo "Testing known color values"
    echo "================================"

    # Manually verified values from the actual neovim.lua files
    declare -A stone_creature_expected=(
        [bg]="#d8d5cd"
        [fg]="#2e2e2e"
        [red]="#d20f39"
        [yellow]="#b85400"
        [blue]="#1e66f5"
    )

    declare -A field_of_dreams_expected=(
        [bg]="#17181a"
        [fg]="#d4d4d4"
        [red]="#b85d5d"
        [yellow]="#a89b6b"
        [blue]="#6b8199"
    )

    local errors=0

    # Test stone-creature
    echo "Checking stone-creature known values:"
    local colors_file
    if colors_file=$(extract_neovim_colors_lua "stone-creature/neovim.lua" 2>/dev/null); then
        for key in "${!stone_creature_expected[@]}"; do
            local expected="${stone_creature_expected[$key]}"
            local actual=$(grep "^${key}=" "$colors_file" | cut -d'=' -f2)

            if [ "$actual" = "$expected" ]; then
                echo "  ✓ $key: $expected"
            else
                echo "  ✗ $key: expected $expected, got $actual"
                errors=$((errors + 1))
            fi
        done
        rm -f "$colors_file"
    else
        echo "  ✗ Extraction failed"
        errors=$((errors + 1))
    fi

    # Test field-of-dreams
    echo "Checking field-of-dreams known values:"
    if colors_file=$(extract_neovim_colors_lua "field-of-dreams/neovim.lua" 2>/dev/null); then
        for key in "${!field_of_dreams_expected[@]}"; do
            local expected="${field_of_dreams_expected[$key]}"
            local actual=$(grep "^${key}=" "$colors_file" | cut -d'=' -f2)

            if [ "$actual" = "$expected" ]; then
                echo "  ✓ $key: $expected"
            else
                echo "  ✗ $key: expected $expected, got $actual"
                errors=$((errors + 1))
            fi
        done
        rm -f "$colors_file"
    else
        echo "  ✗ Extraction failed"
        errors=$((errors + 1))
    fi

    if [ $errors -eq 0 ]; then
        echo "✓ All known values match"
        return 0
    else
        echo "✗ Found $errors mismatches"
        return 1
    fi
}

# Run all tests
main() {
    echo "========================================"
    echo "Comprehensive Color Extraction Test Suite"
    echo "========================================"
    echo ""

    local total=0
    local passed=0

    for theme in stone-creature field-of-dreams; do
        total=$((total + 3))

        test_color_correctness "$theme" && passed=$((passed + 1))
        echo ""

        test_hex_format "$theme" && passed=$((passed + 1))
        echo ""

        test_required_colors "$theme" && passed=$((passed + 1))
        echo ""
    done

    total=$((total + 2))
    test_error_handling && passed=$((passed + 1))
    echo ""

    test_known_values && passed=$((passed + 1))
    echo ""

    echo "========================================"
    echo "Test Results: $passed/$total tests passed"
    echo "========================================"

    if [ $passed -eq $total ]; then
        echo "✓ All tests passed!"
        return 0
    else
        echo "✗ Some tests failed"
        return 1
    fi
}

main "$@"
