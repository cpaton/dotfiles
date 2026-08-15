vim.lsp.config("roslyn", {
    on_attach = function(client, bufnr)
        -- your keymaps, formatting, etc.
    end,
    settings = {
        ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "fullSolution",
            dotnet_compiler_diagnostics_scope = "fullSolution"
        },
        ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
            -- language server doesn't support running tests as that is done by vscode so disable in neovim
            dotnet_enable_tests_code_lens = false,
        },
        ["csharp|completion"] = {
            dotnet_provide_regex_completions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true
        },
        ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_variable_types = false,
            csharp_enable_inlay_hints_for_implicit_object_creation = false,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_parameters = false,
        },
        ["csharp|symbol_search"] = {
            dotnet_search_reference_assemblies = true
        },
        ["csharp|formatting"] = {
            dotnet_organize_imports_on_format = true
        }
    },
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        if client and (client.name == "roslyn" or client.name == "roslyn_ls") then
            vim.api.nvim_create_autocmd("InsertCharPre", {
                desc = "Roslyn: Trigger an auto insert on '/'.",
                buffer = bufnr,
                callback = function()
                    local char = vim.v.char

                    if char ~= "/" then
                        return
                    end

                    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                    row, col = row - 1, col + 1
                    local uri = vim.uri_from_bufnr(bufnr)

                    local params = {
                        _vs_textDocument = { uri = uri },
                        _vs_position = { line = row, character = col },
                        _vs_ch = char,
                        _vs_options = {
                            tabSize = vim.bo[bufnr].tabstop,
                            insertSpaces = vim.bo[bufnr].expandtab,
                        },
                    }

                    -- NOTE: We should send textDocument/_vs_onAutoInsert request only after
                    -- buffer has changed.
                    vim.defer_fn(function()
                        client:request(
                        ---@diagnostic disable-next-line: param-type-mismatch
                            "textDocument/_vs_onAutoInsert",
                            params,
                            function(err, result, _)
                                if err or not result then
                                    return
                                end

                                vim.snippet.expand(result._vs_textEdit.newText)
                            end,
                            bufnr
                        )
                    end, 1)
                end,
            })
        end
    end,
})
