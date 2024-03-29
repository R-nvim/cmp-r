local cmp = require("cmp")

local rhelp_opts = {
    "\\Alpha",
    "\\Beta",
    "\\Chi",
    "\\Delta",
    "\\Epsilon",
    "\\Eta",
    "\\Gamma",
    "\\Iota",
    "\\Kappa",
    "\\Lambda",
    "\\Mu",
    "\\Nu",
    "\\Omega",
    "\\Omicron",
    "\\Phi",
    "\\Pi",
    "\\Psi",
    "\\R",
    "\\Rdversion",
    "\\Rho",
    "\\S4method",
    "\\Sexpr",
    "\\Sigma",
    "\\Tau",
    "\\Theta",
    "\\Upsilon",
    "\\Xi",
    "\\Zeta",
    "\\acronym",
    "\\alias",
    "\\alpha",
    "\\arguments",
    "\\author",
    "\\beta",
    "\\bold",
    "\\chi",
    "\\cite",
    "\\code",
    "\\command",
    "\\concept",
    "\\cr",
    "\\dQuote",
    "\\delta",
    "\\deqn",
    "\\describe",
    "\\description",
    "\\details",
    "\\dfn",
    "\\docType",
    "\\dontrun",
    "\\dontshow",
    "\\donttest",
    "\\dots",
    "\\email",
    "\\emph",
    "\\encoding",
    "\\enumerate",
    "\\env",
    "\\epsilon",
    "\\eqn",
    "\\eta",
    "\\examples",
    "\\file",
    "\\format",
    "\\gamma",
    "\\ge",
    "\\href",
    "\\iota",
    "\\item",
    "\\itemize",
    "\\kappa",
    "\\kbd",
    "\\keyword",
    "\\lambda",
    "\\ldots",
    "\\le",
    "\\link",
    "\\linkS4class",
    "\\method",
    "\\mu",
    "\\name",
    "\\newcommand",
    "\\note",
    "\\nu",
    "\\omega",
    "\\omicron",
    "\\option",
    "\\phi",
    "\\pi",
    "\\pkg",
    "\\preformatted",
    "\\psi",
    "\\references",
    "\\renewcommand",
    "\\rho",
    "\\sQuote",
    "\\samp",
    "\\section",
    "\\seealso",
    "\\sigma",
    "\\source",
    "\\special",
    "\\strong",
    "\\subsection",
    "\\synopsis",
    "\\tab",
    "\\tabular",
    "\\tau",
    "\\testonly",
    "\\theta",
    "\\title",
    "\\upsilon",
    "\\url",
    "\\usage",
    "\\value",
    "\\var",
    "\\verb",
    "\\xi",
    "\\zeta",
}

local M = {}

M.get_keys = function()
    local rhopts = {}
    for _, v in pairs(rhelp_opts) do
        table.insert(rhopts, {
            word = v,
            label = v,
            kind = cmp.lsp.CompletionItemKind.TypeParameter,
        })
    end
    return rhopts
end

return M
