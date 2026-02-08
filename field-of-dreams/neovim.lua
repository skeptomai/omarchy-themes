return {
    {
        "bjarneo/aether.nvim",
        branch = "v2",
        name = "aether",
        priority = 1000,
        opts = {
            transparent = false,
            colors = {
                -- Background colors
                bg = "#17181a",
                bg_dark = "#0f1012",
                bg_highlight = "#2a2a2a",

                -- Foreground colors
                -- fg: Object properties, builtin types, builtin variables, member access, default text
                fg = "#d4d4d4",
                -- fg_dark: Inactive elements, statusline, secondary text
                fg_dark = "#9a9a9a",
                -- comment: Line highlight, gutter elements, disabled states
                comment = "#6a6a6a",

                -- Accent colors
                -- red: Errors, diagnostics, tags, deletions, breakpoints
                red = "#b85d5d",
                -- orange: Constants, numbers, current line number, git modifications
                orange = "#997a5d",
                -- yellow: Types, classes, constructors, warnings, numbers, booleans
                yellow = "#a89b6b",
                -- green: Comments, strings, success states, git additions
                green = "#7a9b7a",
                -- cyan: Parameters, regex, preprocessor, hints, properties
                cyan = "#669999",
                -- blue: Functions, keywords, directories, links, info diagnostics
                blue = "#6b8199",
                -- purple: Storage keywords, special keywords, identifiers, namespaces
                purple = "#8d7a99",
                -- magenta: Function declarations, exception handling, tags
                magenta = "#997a8d",
            },
        },
        config = function(_, opts)
            require("aether").setup(opts)
            vim.cmd.colorscheme("aether")

            -- Enable hot reload
            require("aether.hotreload").setup()
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "aether",
        },
    },
}
