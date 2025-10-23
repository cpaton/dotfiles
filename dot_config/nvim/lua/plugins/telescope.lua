-- https://github.com/nvim-telescope/telescope.nvim
-- highly extendable fuzzy finder over lists
-- non vim dependencies:
--   rigrep - https://github.com/BurntSushi/ripgrep
--   fd - https://github.com/sharkdp/fd
return {
    {
        -- provides more performant list sorting in telescope
        "nvim-telescope/telescope-fzy-native.nvim",
    },
    {
        -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
        -- Building on windows can be fun - need to install cmake, but the version used by this plugin is old and needs compatibility flags
        -- Then the build put the libfzf.dll file under the build/Release folder but it was looking in the build folder only
        -- had to run
        -- ~\AppData\Local\nvim-data\lazy\telescope-fzf-native.nvim\build\Release main ≡ # cp .\libfzf.dll ..
        'nvim-telescope/telescope-fzf-native.nvim',
        -- build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && cmake --build build --config Release'
        build = function()
            local is_windows = vim.loop.os_uname().sysname:match("Windows")
            if is_windows then
                -- Windows build (with CMake and compatibility flag)
                vim.fn.system({
                    "cmake",
                    "-S.",
                    "-Bbuild",
                    "-DCMAKE_BUILD_TYPE=Release",
                    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
                })
                vim.fn.system({ "cmake", "--build", "build", "--config", "Release" })
                -- copy DLL to expected location
                -- vim.fn.copy("build/Release/libfzf.dll", "build/libfzf.dll")
            else
                -- Linux/macOS build (default Makefile)
                vim.fn.system("make")
            end
        end
    },
    {
        -- ui-select extension to replace vim.ui.select with Telescope
        "nvim-telescope/telescope-ui-select.nvim",
    },
    {
        "nvim-telescope/telescope.nvim",
        branch = '0.1.x', -- recommend not using master branch for stability
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzy-native.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
        },
        config = function()
            local tele = require("telescope")
            local themes = require("telescope.themes")
            tele.setup({
                extensions = {
                    fzf = {
                        fuzzy = true,                   -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true,    -- override the file sorter
                        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                    },
                    fzy_native = {
                        override_generic_sorter = false,
                        override_file_sorter = true,
                    },
                    ["ui-select"] = themes.get_dropdown({})
                }
            })
            tele.load_extension("fzf")
            -- tele.load_extension("fzy_native")
            tele.load_extension("ui-select")
        end
    }
}
