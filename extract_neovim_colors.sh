#!/bin/bash
# Phase 1: Lua Interpreter Extraction
# Extracts colors from neovim.lua using nvim -l, lua, or luajit

extract_neovim_colors_lua() {
    local nvim_file="$1"
    local temp_output=$(mktemp)
    local temp_script=$(mktemp --suffix=.lua)

    # Determine which Lua interpreter to use
    local lua_cmd=""
    local lua_method=""

    # Prefer Neovim's Lua (nvim -l)
    if command -v nvim >/dev/null 2>&1; then
        lua_cmd="nvim"
        lua_method="neovim"
        echo "INFO: Using Neovim's Lua interpreter" >&2
    # Fall back to system lua/luajit
    elif command -v luajit >/dev/null 2>&1; then
        lua_cmd="luajit"
        lua_method="system"
        echo "INFO: Using system luajit interpreter" >&2
    elif command -v lua >/dev/null 2>&1; then
        lua_cmd="lua"
        lua_method="system"
        echo "INFO: Using system lua interpreter" >&2
    else
        echo "INFO: No Lua interpreter found, will try AWK method" >&2
        rm -f "$temp_output" "$temp_script"
        return 1
    fi

    # Create Lua extraction script
    cat > "$temp_script" << 'LUA_SCRIPT'
-- Extract colors from neovim.lua config file
local nvim_file = arg[1]

io.stderr:write("-- Loading config file: " .. nvim_file .. "\n")

-- Load the config file
local success, config = pcall(dofile, nvim_file)
if not success then
    io.stderr:write("ERROR: Failed to load config file: " .. tostring(config) .. "\n")
    os.exit(1)
end

io.stderr:write("-- Config loaded successfully\n")

-- Verbosely search for colors table
io.stderr:write("-- Searching for colors table in config structure\n")

local colors = nil

-- Try to find colors dynamically
local function find_colors(tbl, path, depth)
    path = path or "config"
    depth = depth or 0

    -- Prevent infinite recursion
    if depth > 10 then
        return nil
    end

    if type(tbl) ~= "table" then
        return nil
    end

    -- Check if this table has a colors key directly
    if tbl.colors and type(tbl.colors) == "table" then
        io.stderr:write("-- Found colors table at: " .. path .. ".colors\n")
        return tbl.colors
    end

    -- Check if this table has opts.colors
    if tbl.opts and type(tbl.opts) == "table" and tbl.opts.colors then
        io.stderr:write("-- Found colors table at: " .. path .. ".opts.colors\n")
        return tbl.opts.colors
    end

    -- Recursively search numeric indices first (common in configs)
    for i = 1, #tbl do
        if type(tbl[i]) == "table" then
            local found = find_colors(tbl[i], path .. "[" .. i .. "]", depth + 1)
            if found then
                return found
            end
        end
    end

    -- Then search string keys
    for k, v in pairs(tbl) do
        if type(k) == "string" and type(v) == "table" and type(tonumber(k)) ~= "number" then
            local found = find_colors(v, path .. "." .. k, depth + 1)
            if found then
                return found
            end
        end
    end

    return nil
end

colors = find_colors(config)

if not colors then
    io.stderr:write("ERROR: Could not find colors table in config\n")
    os.exit(1)
end

-- Count colors
local color_count = 0
for _ in pairs(colors) do
    color_count = color_count + 1
end
io.stderr:write("-- Found " .. color_count .. " color entries\n")

-- Extract and validate all colors
local extracted = 0
local warned = 0

-- Sort keys for consistent output
local sorted_keys = {}
for k in pairs(colors) do
    table.insert(sorted_keys, k)
end
table.sort(sorted_keys)

for _, key in ipairs(sorted_keys) do
    local value = colors[key]
    if type(value) == "string" then
        -- Validate hex format: #RRGGBB
        if value:match("^#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
            io.stdout:write(key .. "=" .. value .. "\n")
            extracted = extracted + 1
        else
            io.stderr:write("-- WARNING: " .. key .. " has invalid format: " .. value .. "\n")
            warned = warned + 1
        end
    elseif type(value) == "boolean" then
        -- Skip boolean values like transparent=false
        io.stderr:write("-- SKIP: " .. key .. " is boolean\n")
    else
        io.stderr:write("-- WARNING: " .. key .. " has non-string value: " .. type(value) .. "\n")
        warned = warned + 1
    end
end

io.stderr:write("-- Successfully extracted " .. extracted .. " valid colors\n")
if warned > 0 then
    io.stderr:write("-- Warnings: " .. warned .. " entries skipped or invalid\n")
end

if extracted < 10 then
    io.stderr:write("ERROR: Too few valid colors found: " .. extracted .. " (need at least 10)\n")
    os.exit(1)
end

os.exit(0)
LUA_SCRIPT

    # Execute Lua script
    local exit_code
    if [ "$lua_method" = "neovim" ]; then
        # Use nvim -l with script file (nvim -l script.lua args...)
        nvim -l "$temp_script" "$nvim_file" > "$temp_output" 2>&1
        exit_code=$?
    else
        # Use system lua/luajit
        $lua_cmd "$temp_script" "$nvim_file" > "$temp_output" 2>&1
        exit_code=$?
    fi

    # Check if execution failed
    if [ $exit_code -ne 0 ]; then
        echo "ERROR: Lua extraction failed (exit code: $exit_code)"
        cat "$temp_output" >&2
        rm -f "$temp_output" "$temp_script"
        return 1
    fi

    # Check for errors in output
    if grep -q "^ERROR:" "$temp_output"; then
        echo "ERROR: Lua script reported errors:"
        grep "^ERROR:" "$temp_output" >&2
        rm -f "$temp_output" "$temp_script"
        return 1
    fi

    # Extract only the color lines (key=value)
    local colors_only=$(mktemp)
    grep -E "^[a-z_]+=#[0-9a-fA-F]{6}$" "$temp_output" > "$colors_only"

    # Show verbose output to stderr
    grep "^--" "$temp_output" >&2

    # Cleanup
    rm -f "$temp_script"

    # Check we got colors
    if [ ! -s "$colors_only" ]; then
        echo "ERROR: No valid colors extracted"
        rm -f "$temp_output" "$colors_only"
        return 1
    fi

    # Move temp file to final output location
    mv "$colors_only" "$temp_output"

    echo "$temp_output"
    return 0
}

# Main test function
test_extraction() {
    local nvim_file="$1"
    local theme_name=$(basename $(dirname "$nvim_file"))

    echo "========================================"
    echo "Testing: $theme_name"
    echo "File: $nvim_file"
    echo "========================================"

    if [ ! -f "$nvim_file" ]; then
        echo "ERROR: File not found: $nvim_file"
        return 1
    fi

    local colors_file
    if colors_file=$(extract_neovim_colors_lua "$nvim_file"); then
        echo ""
        echo "✓ SUCCESS: Extracted colors to: $colors_file"
        echo ""
        echo "Extracted colors:"
        echo "----------------"
        cat "$colors_file"
        echo ""
        echo "Color count: $(wc -l < "$colors_file")"

        # Cleanup
        rm -f "$colors_file"
        return 0
    else
        echo ""
        echo "✗ FAILED: Could not extract colors"
        return 1
    fi
}

# If script is run directly, test both themes
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "Phase 1 Test: Lua Interpreter Extraction"
    echo "========================================="
    echo ""

    success_count=0
    total_count=0

    for theme in stone-creature field-of-dreams; do
        total_count=$((total_count + 1))
        if test_extraction "$(dirname "$0")/$theme/neovim.lua"; then
            success_count=$((success_count + 1))
        fi
        echo ""
    done

    echo "========================================"
    echo "Test Results: $success_count/$total_count themes extracted successfully"
    echo "========================================"

    if [ $success_count -eq $total_count ]; then
        echo "✓ All tests passed!"
        exit 0
    else
        echo "✗ Some tests failed"
        exit 1
    fi
fi
