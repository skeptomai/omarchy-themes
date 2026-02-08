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
                bg = "#d8d5cd",
                bg_dark = "#cbc8c0",
                bg_highlight = "#c3c0b8",

                -- Foreground colors
                -- fg: Object properties, builtin types, builtin variables, member access, default text
                fg = "#2e2e2e",
                -- fg_dark: Inactive elements, statusline, secondary text
                fg_dark = "#5c5f77",
                -- comment: Line highlight, gutter elements, disabled states
                comment = "#9ca0b0",

                -- Accent colors
                -- red: Errors, diagnostics, tags, deletions, breakpoints
                red = "#d20f39",
                -- orange: Constants, numbers, current line number, git modifications
                orange = "#fe640b",
                -- yellow: Types, classes, constructors, warnings, numbers, booleans
                yellow = "#b85400",
                -- green: Comments, strings, success states, git additions
                green = "#40a02b",
                -- cyan: Parameters, regex, preprocessor, hints, properties
                cyan = "#179299",
                -- blue: Functions, keywords, directories, links, info diagnostics
                blue = "#1e66f5",
                -- purple: Storage keywords, special keywords, identifiers, namespaces
                purple = "#8839ef",
                -- magenta: Function declarations, exception handling, tags
                magenta = "#8839ef",
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
