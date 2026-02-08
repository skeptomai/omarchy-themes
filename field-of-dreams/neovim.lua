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
                bg_dark = "#17181a",
                bg_highlight = "#888a8f",

                -- Foreground colors
                -- fg: Object properties, builtin types, builtin variables, member access, default text
                fg = "#ede9df",
                -- fg_dark: Inactive elements, statusline, secondary text
                fg_dark = "#c9c1a7",
                -- comment: Line highlight, gutter elements, disabled states
                comment = "#888a8f",

                -- Accent colors
                -- red: Errors, diagnostics, tags, deletions, breakpoints
                red = "#c2a566",
                -- orange: Constants, numbers, current line number, git modifications
                orange = "#dfcda5",
                -- yellow: Types, classes, constructors, warnings, numbers, booleans
                yellow = "#bfaf78",
                -- green: Comments, strings, success states, git additions
                green = "#cab86d",
                -- cyan: Parameters, regex, preprocessor, hints, properties
                cyan = "#afb8c6",
                -- blue: Functions, keywords, directories, links, info diagnostics
                blue = "#929dc3",
                -- purple: Storage keywords, special keywords, identifiers, namespaces
                purple = "#a7afbe",
                -- magenta: Function declarations, exception handling, tags
                magenta = "#dbdfe5",
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
