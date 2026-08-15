return {
    {
        "seblyng/roslyn.nvim",
        ---@module 'roslyn.config'
        ---@type RoslynNvimConfig
        opts = {},
    },
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")

            dap.adapters.coreclr = {
                type = "executable",
                command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
                args = { "--interpreter=vscode" },
            }

            dap.configurations.cs = {
                {
                    type = "coreclr",
                    name = "Launch",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
                    end,
                },
                {
                    type = "coreclr",
                    name = "Attach",
                    request = "attach",
                    processId = require("dap.utils").pick_process,
                },
            }
        end,
    },
}
