local cmp = require("cmp")

local M = {}

--- Get fig and tbl labels
---@param input string
---@return table
M.get_labels = function(input)
    local resp = {}

    -- Get local labels
    local lines = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, true)
    local header = {}
    for _, v in pairs(lines) do
        if v:find("^#| ") then
            if v:find("#| label: ") then
                local lbl = v:gsub("#| label:%s*", ""):gsub("'", ""):gsub('"', "")
                if lbl:find("^tbl") or lbl:find("^fig") then
                    lbl = "@" .. lbl
                    if lbl:find("^" .. input) then header.label = lbl end
                end
            elseif v:find("#| fig%-cap: ") or v:find("#| tbl%-cap: ") then
                local cap = v:gsub("#| ...-cap:%s*", ""):gsub("'", ""):gsub('"', "")
                header.caption = cap
            end
        else
            if #header and header.label then
                local item = {
                    label = header.label,
                    kind = cmp.lsp.CompletionItemKind.Reference,
                }
                if header.caption then
                    item.documentation = {
                        kind = cmp.lsp.MarkupKind.Markdown,
                        value = header.caption,
                    }
                end
                table.insert(resp, item)
                header = {}
            end
        end
    end
    return resp
end

return M
