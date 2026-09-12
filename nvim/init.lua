-- Disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("jovani.core.init")
require("jovani.lazy")
require("jovani.lsp")

-- Auto-save on insert leave or normal-mode text change
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = "*",
  command = "silent! write",
  nested = true,
})

-- Colortheme picker
if vim.fn.executable("recol") == 1 then
  local launch_interactive_mode = function()
    local width = math.floor(vim.o.columns * 0.75)
    local height = math.floor(vim.o.lines * 0.75)
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height - 3) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      border = "rounded",
      title = " Recol ",
      title_pos = "center",
    })
    vim.bo[buf].bufhidden = "wipe"
    vim.fn.termopen({ "recol", "-i", "--quit-on-select" }, {
      on_exit = function()
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
          vim.cmd.source("~/.config/nvim/init.lua")
        end)
      end,
    })
    vim.cmd.startinsert()
  end
  vim.api.nvim_create_user_command("RecolOpen", function()
    launch_interactive_mode()
  end, { nargs = 0 })
end

-- recol:start
-- GitHub Dark
local function applyRecolTheme()
    vim.cmd("highlight clear")
    if vim.fn.has("syntax_on") then vim.cmd("syntax reset") end
    local P = {
        black   = { "#000000", "#4d4d4d" },
        red     = { "#f78166", "#f78166" },
        green   = { "#56d364", "#56d364" },
        yellow  = { "#e3b341", "#e3b341" },
        blue    = { "#6ca4f8", "#6ca4f8" },
        magenta = { "#db61a2", "#db61a2" },
        cyan    = { "#2b7489", "#2b7489" },
        white   = { "#ffffff", "#ffffff" },
        orange  = { "#ed9a54", "#ed9a54" },
        pink    = { "#fbc0b3", "#fbc0b3" },
        bg = { "#08090b", "#101216", "#1b1f25", "#262b35", "#3b4251" },
        fg = { "#98a2ad", "#8b949e", "#575d63", "#2d3033" },
        sel = { "#23262b", "#2d3034" },
        cur = { 
            bg = "#c9d1d9",
            fg = "#101216",
        },
        comment = "#5a6068",
        status_line = "#08090b",
        diff = {
            add = "#33733d",
            delete = "#844a3e",
            change = "#3e5b87",
            text = "#61324e",
        }
    }
    local spec = {
        diag = {
            error = P.red[1],
            warn  = P.yellow[1],
            info  = P.blue[1],
            hint  = P.green[1],
            ok    = P.green[1],
        },
        git = {
            add      = P.green[1],
            removed  = P.red[1],
            changed  = P.blue[1],
            conflict = P.yellow[1],
            ignored  = P.comment,
        }
    }
    local syn = {
        bracket     = P.fg[3],
        builtin0    = P.red[1],
        builtin1    = P.cyan[2],
        builtin2    = P.orange[2],
        builtin3    = P.red[2],
        comment     = P.comment,
        conditional = P.magenta[2],
        const       = P.orange[2],
        dep         = P.fg[4],
        field       = P.blue[1],
        func        = P.blue[2],
        ident       = P.cyan[1],
        keyword     = P.magenta[1],
        number      = P.orange[1],
        operator    = P.fg[3],
        preproc     = P.pink[2],
        regex       = P.yellow[2],
        statement   = P.magenta[1],
        string      = P.green[1],
        type        = P.yellow[1],
        variable    = P.fg[2],
    }
    local trans = false
    local inactive = false
    local inv = {
        match_paren = false,
        visual = false,
        search = false,
    }
    local stl = {
        comments = "NONE",
        conditionals = "NONE",
        constants = "NONE",
        functions = "NONE",
        keywords = "NONE",
        numbers = "NONE",
        operators = "NONE",
        preprocs = "NONE",
        strings = "NONE",
        types = "NONE",
        variables = "NONE",
    }

    for group, opts in pairs({
        ColorColumn  = { bg = P.bg[3] },
        Conceal      = { fg = P.bg[5] },
        Cursor       = { fg = P.cur.fg, bg = P.cur.bg },
        lCursor      = { link = "Cursor" },
        CursorIM     = { link = "Cursor" },
        CursorColumn = { link = "CursorLine" },
        CursorLine   = { bg = P.bg[4] },
        Directory    = { fg = syn.func },
        DiffAdd      = { bg = P.diff.add },
        DiffChange   = { bg = P.diff.change },
        DiffDelete   = { bg = P.diff.delete },
        DiffText     = { bg = P.diff.text },
        EndOfBuffer  = { fg = P.bg[2] },
        ErrorMsg     = { fg = spec.diag.error },
        WinSeparator = { fg = P.bg[1] },
        VertSplit    = { link = "WinSeparator" },
        Folded       = { fg = P.fg[4], bg = P.bg[3] },
        FoldColumn   = { fg = P.fg[4] },
        SignColumn   = { fg = P.fg[4] },
        SignColumnSB = { link = "SignColumn" },
        Substitute   = { fg = P.bg[2], bg = spec.diag.error },
        LineNr       = { fg = P.fg[4] },
        CursorLineNr = { fg = spec.diag.warn, style = "bold" },
        MatchParen   = { fg = spec.diag.warn, style = inv.match_paren and "reverse,bold" or "bold" },
        ModeMsg      = { fg = spec.diag.warn, style = "bold" },
        MoreMsg      = { fg = spec.diag.info, style = "bold" },
        NonText      = { fg = P.bg[5] },
        Normal       = { fg = P.fg[2], bg = trans and "NONE" or P.bg[2] },
        NormalNC     = { fg = P.fg[2], bg = (inactive and P.bg[1]) or (trans and "NONE") or P.bg[2] },
        NormalFloat  = { fg = P.fg[2], bg = P.bg[1] },
        FloatBorder  = { fg = P.fg[4] },
        Pmenu        = { fg = P.fg[2], bg = P.sel[1] },
        PmenuSel     = { bg = P.sel[2] },
        PmenuSbar    = { link = "Pmenu" },
        PmenuThumb   = { bg = P.sel[2] },
        Question     = { link = "MoreMsg" },
        QuickFixLine = { link = "CursorLine" },
        Search       = inv.search and { style = "reverse" } or { fg = P.fg[2], bg = P.sel[2] },
        IncSearch    = inv.search and { style = "reverse" } or { fg = P.bg[2], bg = spec.diag.hint },
        CurSearch    = { link = "IncSearch" },
        SpecialKey   = { link = "NonText" },
        SpellBad     = { sp = spec.diag.error, style = "undercurl" },
        SpellCap     = { sp = spec.diag.warn, style = "undercurl" },
        SpellLocal   = { sp = spec.diag.info, style = "undercurl" },
        SpellRare    = { sp = spec.diag.info, style = "undercurl" },
        StatusLine   = { fg = P.fg[3], bg = P.status_line },
        StatusLineNC = { fg = P.fg[4], bg = P.status_line },
        TabLine      = { fg = P.fg[3], bg = P.bg[3] },
        TabLineFill  = { bg = P.bg[1] },
        TabLineSel   = { fg = P.bg[2], bg = P.fg[4] },
        Title        = { fg = syn.func, style = "bold" },
        Visual       = inv.visual and { style = "reverse" } or { bg = P.sel[1] },
        VisualNOS    = inv.visual and { style = "reverse" } or { link = "Visual" },
        WarningMsg   = { fg = spec.diag.warn },
        Whitespace   = { fg = P.bg[4] },
        WildMenu     = { link = "Pmenu" },
        WinBar       = { fg = P.fg[4], bg = trans and "NONE" or P.bg[2], style = "bold" },
        WinBarNC     = { fg = P.fg[4], bg = trans and "NONE" or inactive and P.bg[1] or P.bg[2], style = "bold" },

        Comment        = { fg = syn.comment, style = stl.comments },
        Constant       = { fg = syn.const, style = stl.constants },
        String         = { fg = syn.string, style = stl.strings },
        Character      = { link = "String" },
        Number         = { fg = syn.number, style = stl.numbers },
        Float          = { link = "Number" },
        Boolean        = { link = "Number" },
        Identifier     = { fg = syn.ident, style = stl.variables },
        Function       = { fg = syn.func, style = stl.functions },
        Statement      = { fg = syn.keyword, style = stl.keywords },
        Conditional    = { fg = syn.conditional, style = stl.conditionals },
        Repeat         = { link = "Conditional" },
        Label          = { link = "Conditional" },
        Operator       = { fg = syn.operator, style = stl.operators },
        Keyword        = { fg = syn.keyword, style = stl.keywords },
        Exception      = { link = "Keyword" },
        PreProc        = { fg = syn.preproc, style = stl.preprocs },
        Include        = { link = "PreProc" },
        Define         = { link = "PreProc" },
        Macro          = { link = "PreProc" },
        PreCondit      = { link = "PreProc" },
        Type           = { fg = syn.type, style = stl.types },
        StorageClass   = { link = "Type" },
        Structure      = { link = "Type" },
        Typedef        = { link = "Type" },
        Special        = { fg = syn.func },
        SpecialChar    = { link = "Special" },
        Tag            = { link = "Special" },
        Delimiter      = { link = "Special" },
        SpecialComment = { link = "Special" },
        Debug          = { link = "Special" },
        Underlined     = { style = "underline" },
        Bold           = { style = "bold" },
        Italic         = { style = "italic" },
        Error          = { fg = spec.diag.error },
        Todo           = { fg = P.bg[2], bg = spec.diag.info },
        qfLineNr       = { link = "LineNr" },
        qfFileName     = { link = "Directory" },
        diffAdded      = { fg = spec.git.add },
        diffRemoved    = { fg = spec.git.removed },
        diffChanged    = { fg = spec.git.changed },
        diffOldFile    = { fg = spec.diag.warn },
        diffNewFile    = { fg = spec.diag.hint },
        diffFile       = { fg = spec.diag.info },
        diffLine       = { fg = syn.builtin2 },
        diffIndexLine  = { fg = syn.preproc },

        DiagnosticError          = { fg = spec.diag.error },
        DiagnosticWarn           = { fg = spec.diag.warn },
        DiagnosticInfo           = { fg = spec.diag.info },
        DiagnosticHint           = { fg = spec.diag.hint },
        DiagnosticOk             = { fg = spec.diag.ok },
        DiagnosticSignError      = { link = "DiagnosticError" },
        DiagnosticSignWarn       = { link = "DiagnosticWarn" },
        DiagnosticSignInfo       = { link = "DiagnosticInfo" },
        DiagnosticSignHint       = { link = "DiagnosticHint" },
        DiagnosticSignOk         = { link = "DiagnosticOk" },
        DiagnosticUnderlineError = { style = "undercurl", sp = spec.diag.error },
        DiagnosticUnderlineWarn  = { style = "undercurl", sp = spec.diag.warn },
        DiagnosticUnderlineInfo  = { style = "undercurl", sp = spec.diag.info },
        DiagnosticUnderlineHint  = { style = "undercurl", sp = spec.diag.hint },
        DiagnosticUnderlineOk    = { style = "undercurl", sp = spec.diag.ok },

        ["@variable"] = { fg = syn.variable, style = stl.variables },
        ["@variable.builtin"] = { fg = syn.builtin0, style = stl.variables },
        ["@variable.parameter"] = { fg = syn.builtin1, style = stl.variables },
        ["@variable.member"] = { fg = syn.field },
        ["@constant"] = { link = "Constant" },
        ["@constant.builtin"] = { fg = syn.builtin2, style = stl.keywords },
        ["@constant.macro"] = { link = "Macro" },
        ["@module"] = { fg = syn.builtin1 },
        ["@label"] = { link = "Label" },
        ["@string"] = { link = "String" },
        ["@string.regexp"] = { fg = syn.regex, style = stl.strings },
        ["@string.escape"] = { fg = syn.regex, style = "bold" },
        ["@string.special"] = { link = "Special" },
        ["@string.special.url"] = { fg = syn.const, style = "italic,underline" },
        ["@character"] = { link = "Character" },
        ["@character.special"] = { link = "SpecialChar" },
        ["@boolean"] = { link = "Boolean" },
        ["@number"] = { link = "Number" },
        ["@number.float"] = { link = "Float" },
        ["@type"] = { link = "Type" },
        ["@type.builtin"] = { fg = syn.builtin1, style = stl.types },
        ["@attribute"] = { link = "Constant" },
        ["@property"] = { fg = syn.field },
        ["@function"] = { link = "Function" },
        ["@function.builtin"] = { fg = syn.builtin0, style = stl.functions },
        ["@function.macro"] = { fg = syn.builtin0, style = stl.functions },
        ["@constructor"] = { fg = syn.ident },
        ["@operator"] = { link = "Operator" },
        ["@keyword"] = { link = "Keyword" },
        ["@keyword.function"] = { fg = syn.keyword, style = stl.functions },
        ["@keyword.operator"] = { fg = syn.operator, style = stl.operators },
        ["@keyword.import"] = { link = "Include" },
        ["@keyword.storage"] = { link = "StorageClass" },
        ["@keyword.repeat"] = { link = "Repeat" },
        ["@keyword.return"] = { fg = syn.builtin0, style = stl.keywords },
        ["@keyword.exception"] = { link = "Exception" },
        ["@keyword.conditional"] = { link = "Conditional" },
        ["@keyword.conditional.ternary"] = { link = "Conditional" },
        ["@punctuation.delimiter"] = { fg = syn.bracket },
        ["@punctuation.bracket"] = { fg = syn.bracket },
        ["@punctuation.special"] = { fg = syn.builtin1, style = stl.operators },
        ["@comment"] = { link = "Comment" },
        ["@comment.error"] = { fg = P.bg[2], bg = spec.diag.error },
        ["@comment.warning"] = { fg = P.bg[2], bg = spec.diag.warn },
        ["@comment.todo"] = { fg = P.bg[2], bg = spec.diag.hint },
        ["@comment.note"] = { fg = P.bg[2], bg = spec.diag.info },
        ["@markup"] = { fg = P.fg[2] },
        ["@markup.strong"] = { fg = P.red[1], style = "bold" },
        ["@markup.italic"] = { link = "Italic" },
        ["@markup.strikethrough"] = { fg = P.fg[2], style = "strikethrough" },
        ["@markup.underline"] = { link = "Underline" },
        ["@markup.heading"] = { link = "Title" },
        ["@markup.quote"] = { fg = P.fg[3] },
        ["@markup.math"] = { fg = syn.func },
        ["@markup.link"] = { fg = syn.keyword, style = "bold" },
        ["@markup.link.label"] = { link = "Special" },
        ["@markup.link.url"] = { fg = syn.const, style = "italic,underline" },
        ["@markup.raw"] = { fg = syn.ident, style = "italic" },
        ["@markup.raw.block"] = { fg = P.pink[1] },
        ["@markup.list"] = { fg = syn.builtin1, style = stl.operators },
        ["@markup.list.checked"] = { fg = P.green[1] },
        ["@markup.list.unchecked"] = { fg = P.yellow[1] },
        ["@diff.plus"] = { link = "diffAdded" },
        ["@diff.minus"] = { link = "diffRemoved" },
        ["@diff.delta"] = { link = "diffChanged" },
        ["@tag"] = { fg = syn.keyword },
        ["@tag.attribute"] = { fg = syn.func, style = "italic" },
        ["@tag.delimiter"] = { fg = syn.builtin1 },
        ["@label.json"] = { fg = syn.func },
        ["@constructor.lua"] = { fg = P.fg[3] },
        ["@field.rust"] = { fg = P.fg[3] },
        ["@variable.member.yaml"] = { fg = syn.func },

        ["@lsp.type.boolean"] = { link = "@boolean" },
        ["@lsp.type.builtinType"] = { link = "@type.builtin" },
        ["@lsp.type.comment"] = { link = "@comment" },
        ["@lsp.type.enum"] = { link = "@type" },
        ["@lsp.type.enumMember"] = { link = "@constant" },
        ["@lsp.type.escapeSequence"] = { link = "@string.escape" },
        ["@lsp.type.formatSpecifier"] = { link = "@punctuation.special" },
        ["@lsp.type.interface"] = { fg = syn.builtin3 },
        ["@lsp.type.keyword"] = { link = "@keyword" },
        ["@lsp.type.namespace"] = { link = "@module" },
        ["@lsp.type.number"] = { link = "@number" },
        ["@lsp.type.operator"] = { link = "@operator" },
        ["@lsp.type.parameter"] = { link = "@parameter" },
        ["@lsp.type.property"] = { link = "@property" },
        ["@lsp.type.selfKeyword"] = { link = "@variable.builtin" },
        ["@lsp.type.typeAlias"] = { link = "@type.definition" },
        ["@lsp.type.unresolvedReference"] = { link = "@error" },
    }) do
        if opts.style and opts.style ~= "NONE" then
            for token in opts.style:gmatch("[^,%s]+") do
                opts[token] = true
            end
        end
        opts.style = nil
        vim.api.nvim_set_hl(0, group, opts)
    end
end
applyRecolTheme()
-- recol:end
