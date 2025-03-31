local cmp = require("cmp")
local send_to_nvimcom

local last_compl_item
local cb_cmp
local cb_rsv
local compl_id = 0
local ter = nil
local qcell_opts = nil
local chunk_opts = nil
local rhelp_keys = nil

-- Translate symbols added by nvimcom to LSP kinds
local kindtbl = {
    ["("] = cmp.lsp.CompletionItemKind.Function, -- function
    ["$"] = cmp.lsp.CompletionItemKind.Struct, -- data.frame
    ["%"] = cmp.lsp.CompletionItemKind.Method, -- logical
    ["~"] = cmp.lsp.CompletionItemKind.Text, -- character
    ["{"] = cmp.lsp.CompletionItemKind.Value, -- numeric
    ["!"] = cmp.lsp.CompletionItemKind.Field, -- factor
    [";"] = cmp.lsp.CompletionItemKind.Constructor, -- control
    ["["] = cmp.lsp.CompletionItemKind.Struct, -- list
    ["<"] = cmp.lsp.CompletionItemKind.Class, -- S4
    [":"] = cmp.lsp.CompletionItemKind.Interface, -- environment
    ["&"] = cmp.lsp.CompletionItemKind.Event, -- promise
    ["l"] = cmp.lsp.CompletionItemKind.Module, -- library
    ["a"] = cmp.lsp.CompletionItemKind.Variable, -- function argument
    ["c"] = cmp.lsp.CompletionItemKind.Field, -- data.frame column
    ["*"] = cmp.lsp.CompletionItemKind.TypeParameter, -- other
}

local options = {
    filetypes = { "r", "rmd", "quarto", "rnoweb", "rhelp" },
    doc_width = 58,
    trigger_characters = { " ", ":", "(", '"', "@", "$" },
    fun_data_1 = { "select", "rename", "mutate", "filter" },
    fun_data_2 = { ggplot = { "aes" }, with = { "*" } },
    quarto_intel = nil,
}

local reset_r_compl = function()
    for _, v in pairs(cmp.core.sources or {}) do
        if v.name == "cmp_r" then
            v:reset()
            break
        end
    end
end

local send_to_nrs = function(msg)
    if vim.g.R_Nvim_status and vim.g.R_Nvim_status > 2 then
        require("r.job").stdin("Server", msg)
    end
end

local fix_doc = function(txt)
    -- The rnvimserver replaces ' with \019 and \n with \020. We have to revert this:
    txt = string.gsub(txt, "\020", "\n")
    txt = string.gsub(txt, "\019", "'")
    txt = string.gsub(txt, "\018", "\\")
    return txt
end

local backtick = function(s)
    local t1 = {}
    for token in string.gmatch(s, "[^$]+") do
        table.insert(t1, token)
    end

    local t3 = {}
    for _, v in pairs(t1) do
        local t2 = {}
        for token in string.gmatch(v, "[^@]+") do
            if
                (not string.find(token, " = $"))
                and (
                    string.find(token, " ")
                    or string.find(token, "^_")
                    or string.find(token, "^[0-9]")
                )
            then
                table.insert(t2, "`" .. token .. "`")
            else
                table.insert(t2, token)
            end
        end
        table.insert(t3, table.concat(t2, "@"))
    end
    return table.concat(t3, "$")
end

local get_piped_obj
get_piped_obj = function(line, lnum)
    local l
    l = vim.fn.getline(lnum - 1)
    if type(l) == "string" and string.find(l, "|>%s*$") then
        return get_piped_obj(l, lnum - 1)
    end
    if type(l) == "string" and string.find(l, "%%>%%%s*$") then
        return get_piped_obj(l, lnum - 1)
    end
    if string.find(line, "|>") then return string.match(line, ".-([%w%._]+)%s*|>") end
    if string.find(line, "%%>%%") then
        return string.match(line, ".-([%w%._]+)%s*%%>%%")
    end
    return nil
end

local get_first_obj = function(line, lnum)
    local no
    local piece
    local funname
    local firstobj
    local pkg
    no = 0
    local op
    op = string.byte("(")
    local cp
    cp = string.byte(")")
    local idx
    repeat
        idx = #line
        while idx > 0 do
            if line:byte(idx) == op then
                no = no + 1
            elseif line:byte(idx) == cp then
                no = no - 1
            end
            if no == 1 then
                -- The opening parenthesis is here. Now, get the function and
                -- its first object (if in the same line)
                piece = string.sub(line, 1, idx - 1)
                funname = string.match(piece, ".-([%w%._]+)%s*$")
                if funname then pkg = string.match(piece, ".-([%w%._]+)::" .. funname) end
                piece = string.sub(line, idx + 1)
                firstobj = string.match(piece, "%s-([%w%.%_]+)")
                if funname then idx = string.find(line, funname) end
                break
            end
            idx = idx - 1
        end
        if funname then break end
        lnum = lnum - 1
        line = vim.fn.getline(lnum)
    until type(line) == "string" and string.find(line, "^%S") or lnum == 0
    return pkg, funname, firstobj, line, lnum, idx
end

local need_R_args = function(line, lnum)
    local funname = nil
    local firstobj = nil
    local funname2 = nil
    local firstobj2 = nil
    local listdf = nil
    local nline = nil
    local nlnum = nil
    local cnum = nil
    local lib = nil
    lib, funname, firstobj, nline, nlnum, cnum = get_first_obj(line, lnum)

    -- Check if this is function for which we expect to complete data frame column names
    if funname then
        -- Check if the data.frame is supposed to be the first argument:
        for _, v in pairs(options.fun_data_1) do
            if v == funname then
                listdf = 1
                break
            end
        end

        -- Check if the data.frame is supposed to be the first argument of the
        -- nesting function:
        if not listdf and cnum > 1 then
            nline = string.sub(nline, 1, cnum)
            for k, v in pairs(options.fun_data_2) do
                for _, a in pairs(v) do
                    if a == "*" or funname == a then
                        _, funname2, firstobj2, nline, nlnum, _ =
                            get_first_obj(nline, nlnum)
                        if funname2 == k then
                            firstobj = firstobj2
                            listdf = 2
                            break
                        end
                    end
                end
            end
        end
    end

    -- Check if the first object was piped
    local pobj = get_piped_obj(nline, nlnum)
    if pobj then firstobj = pobj end
    local resp
    resp = {
        lib = lib,
        fnm = funname,
        fnm2 = funname2,
        firstobj = firstobj,
        listdf = listdf,
        firstobj2 = firstobj2,
        pobj = pobj,
    }
    return resp
end

local source = {}

source.new = function()
    local self = setmetatable({}, { __index = source })
    return self
end

source.setup = function(opts)
    options = vim.tbl_extend("force", options, opts or {})
    if options.doc_width < 30 or options.doc_width > 160 then options.doc_width = 58 end
    vim.env.CMPR_DOC_WIDTH = tostring(options.doc_width)
    if vim.g.R_Nvim_status and vim.g.R_Nvim_status > 2 then
        local job = require("r.job")
        job.stdin("Server", "45" .. tostring(options.doc_width) .. "\n")
    end
end

source.get_keyword_pattern = function()
    return "[`\\._@\\$:_[:digit:][:lower:][:upper:]\\u00FF-\\uFFFF]*"
end

source.get_trigger_characters = function() return options.trigger_characters end

source.get_debug_name = function() return "cmp_r" end

source.is_available = function()
    for _, v in pairs(options.filetypes) do
        if vim.bo.filetype == v then return true end
    end
    return false
end

source.resolve = function(_, citem, callback)
    cb_rsv = callback
    last_compl_item = citem

    if not citem.cls then
        callback(citem)
        return nil
    end

    if citem.env == ".GlobalEnv" then
        if citem.cls == "a" then
            callback(citem)
        elseif
            citem.cls == "!"
            or citem.cls == "%"
            or citem.cls == "~"
            or citem.cls == "{"
        then
            send_to_nvimcom(
                "E",
                "nvimcom:::nvim.get.summary(" .. citem.label .. ", '" .. citem.env .. "')"
            )
        elseif citem.cls == "(" then
            send_to_nvimcom(
                "E",
                'nvimcom:::nvim.GlobalEnv.fun.args("' .. citem.label .. '")'
            )
        else
            send_to_nvimcom(
                "E",
                "nvimcom:::nvim.min.info(" .. citem.label .. ", '" .. citem.env .. "')"
            )
        end
        return nil
    end

    -- Column of data.frame for fun_data_1 or fun_data_2
    if citem.cls == "c" then
        send_to_nvimcom(
            "E",
            "nvimcom:::nvim.get.summary("
                .. citem.env
                .. "$"
                .. citem.label
                .. ", '"
                .. citem.env
                .. "')"
        )
    elseif citem.cls == "a" then
        local itm = citem.label:gsub(" = ", "")
        local pf = vim.fn.split(citem.env, "\002")
        send_to_nrs("7" .. pf[1] .. "\002" .. pf[2] .. "\002" .. itm .. "\n")
    elseif citem.cls == "l" then
        citem.documentation = {
            value = fix_doc(citem.env),
            kind = cmp.lsp.MarkupKind.Markdown,
        }
        callback(citem)
    elseif
        citem.label:find("%$")
        and (citem.cls == "!" or citem.cls == "%" or citem.cls == "~" or citem.cls == "{")
    then
        send_to_nvimcom(
            "E",
            "nvimcom:::nvim.get.summary(" .. citem.label .. ", '" .. citem.env .. "')"
        )
    else
        send_to_nrs("6" .. citem.label .. "\002" .. citem.env .. "\n")
    end
end

source.complete = function(_, request, callback)
    if not vim.g.R_Nvim_status or vim.g.R_Nvim_status < 3 then return end
    cb_cmp = callback

    if not send_to_nvimcom then send_to_nvimcom = require("r.run").send_to_nvimcom end

    -- Check if this is Rmd and the cursor is in the chunk header
    if
        request.context.filetype == "rmd"
        and string.find(request.context.cursor_before_line, "^```{r")
    then
        if not chunk_opts then chunk_opts = require("cmp_r.chunk").get_opts() end
        callback({ items = chunk_opts })
        return
    end

    -- Check if the cursor is in R code
    local lang = "r"
    if request.context.filetype ~= "r" then
        lang = "other"
        local lines = vim.api.nvim_buf_get_lines(
            request.context.bufnr,
            0,
            request.context.cursor.row,
            true
        )
        local lnum = request.context.cursor.row
        if request.context.filetype == "rmd" or request.context.filetype == "quarto" then
            lang = require("r.utils").get_lang()
            if lang == "markdown_inline" then
                local wrd = string.sub(request.context.cursor_before_line, request.offset)
                if wrd == "@" then
                    reset_r_compl()
                elseif wrd:find("^@[tf]") then
                    local lbls = require("cmp_r.figtbl").get_labels(wrd)
                    callback({ items = lbls })
                end
                return {}
            end
        elseif request.context.filetype == "rnoweb" then
            for i = lnum, 1, -1 do
                if string.find(lines[i], "^%s*<<.*>>=") then
                    lang = "r"
                    break
                elseif string.find(lines[i], "^@") then
                    return {}
                end
            end
        elseif request.context.filetype == "rhelp" then
            for i = lnum, 1, -1 do
                if string.find(lines[i], [[\%S+{]]) then
                    if
                        string.find(lines[i], [[\examples{]])
                        or string.find(lines[i], [[\usage{]])
                    then
                        lang = "r"
                    end
                    break
                end
            end
            if lang ~= "r" then
                local wrd = string.sub(request.context.cursor_before_line, request.offset)
                if #wrd == 0 then
                    reset_r_compl()
                    return nil
                end
                if wrd == "\\" then
                    if not rhelp_keys then
                        rhelp_keys = require("cmp_r.rhelp").get_keys()
                    end
                    callback({ items = rhelp_keys })
                    return
                end
            end
        end
    end

    -- Is the current cursor position within the YAML header of an R or Python block of code?
    if
        (lang == "r" or lang == "python")
        and string.find(request.context.cursor_before_line, "^#| ")
    then
        if
            string.find(request.context.cursor_before_line, "^#| .*:")
            and not string.find(request.context.cursor_before_line, "^#| .*: !expr ")
        then
            return nil
        end
        if not string.find(request.context.cursor_before_line, "^#| .*: !expr ") then
            if not qcell_opts then
                qcell_opts = require("cmp_r.quarto").get_cell_opts(options.quarto_intel)
            end
            callback({ items = qcell_opts })
            return
        end
    end

    if lang ~= "r" then return {} end

    -- check if the cursor is within comment or string
    local snm = ""
    local c = vim.treesitter.get_captures_at_pos(
        0,
        request.context.cursor.row - 1,
        request.context.cursor.col - 2
    )
    if #c > 0 then
        for _, v in pairs(c) do
            if v.capture == "string" then
                snm = "rString"
            elseif v.capture == "comment" then
                return nil
            end
        end
    else
        -- We still need to call synIDattr because there is no treesitter parser for rhelp
        snm = vim.fn.synIDattr(
            vim.fn.synID(request.context.cursor.row, request.context.cursor.col - 1, 1),
            "name"
        )
        if snm == "rComment" then return nil end
    end

    -- required by rnvimserver
    compl_id = compl_id + 1

    local wrd = string.sub(request.context.cursor_before_line, request.offset)
    wrd = string.gsub(wrd, "`", "")
    ter = {
        start = {
            line = request.context.cursor.line,
            character = request.offset - 1,
        },
        ["end"] = {
            line = request.context.cursor.line,
            character = request.context.cursor.character,
        },
    }

    -- Should we complete function arguments?
    local nra
    nra = need_R_args(request.context.cursor_before_line, request.context.cursor.row)

    if nra.fnm then
        -- We are passing arguments for a function

        -- Special completion for library and require
        if
            (nra.fnm == "library" or nra.fnm == "require")
            and (not nra.firstobj or nra.firstobj == wrd)
        then
            send_to_nrs("5" .. compl_id .. "\003\004" .. wrd .. "\n")
            return nil
        end

        if snm == "rString" then return nil end

        if vim.g.R_Nvim_status < 7 then
            -- Get the arguments of the first function whose name matches nra.fnm
            if nra.lib then
                send_to_nrs(
                    "5"
                        .. compl_id
                        .. "\003\005"
                        .. wrd
                        .. "\005"
                        .. nra.lib
                        .. "::"
                        .. nra.fnm
                        .. "\n"
                )
            else
                send_to_nrs(
                    "5" .. compl_id .. "\003\005" .. wrd .. "\005" .. nra.fnm .. "\n"
                )
            end
            return nil
        else
            -- Get arguments according to class of first object
            local msg
            msg = 'nvimcom:::nvim_complete_args("'
                .. compl_id
                .. '", "'
                .. nra.fnm
                .. '", "'
                .. wrd
                .. '"'
            if nra.firstobj then
                msg = msg .. ', firstobj = "' .. nra.firstobj .. '"'
            elseif nra.lib then
                msg = msg .. ', lib = "' .. nra.lib .. '"'
            end
            if nra.firstobj and nra.listdf then msg = msg .. ", ldf = TRUE" end
            msg = msg .. ")"

            -- Save documentation of arguments to be used by rnvimserver
            send_to_nvimcom("E", msg)
            return nil
        end
    end

    if snm == "rString" then return nil end

    if #wrd == 0 then
        reset_r_compl()
        return nil
    end

    send_to_nrs("5" .. compl_id .. "\003" .. wrd .. "\n")

    return nil
end

---Callback function for source.resolve(). When cmp_r doesn't have the necessary
---data for resolving the completion (which happens in most cases), it request
---the data to rnvimserver which calls back this function.
---@param txt string The text almost ready to be displayed.
source.resolve_cb = function(txt)
    local s = fix_doc(txt)
    if last_compl_item.def then
        s = last_compl_item.label .. fix_doc(last_compl_item.def) .. "\n---\n" .. s
    end
    last_compl_item.documentation = { kind = cmp.lsp.MarkupKind.Markdown, value = s }
    cb_rsv({ items = { last_compl_item } })
end

---Callback function for source.complete(). When cmp_r doesn't have the
---necessary data for completion (which happens in most cases), it request the
---completion data to rnvimserver which calls back this function.
---@param cid number The completion ID.
---@param compl table The completion data.
source.complete_cb = function(cid, compl)
    if cid ~= compl_id then return nil end

    local resp = {}
    for _, v in pairs(compl) do
        local lbl = string.gsub(v.label, "\019", "'")
        table.insert(resp, {
            label = lbl,
            env = v.env,
            cls = v.cls,
            def = v.def or nil,
            kind = kindtbl[v.cls],
            sortText = v.cls == "a" and "0" or "9",
            textEdit = { newText = backtick(lbl), range = ter },
        })
    end
    cb_cmp(resp)
end

return source
