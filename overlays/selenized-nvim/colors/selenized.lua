-- Selenized color scheme for Neovim
-- Based on https://github.com/jan-warchol/selenized
-- Extended from https://github.com/calind/selenized.nvim to include all 4 variants
--
-- Variants:
--   dark  - original selenized dark
--   black - OLED-friendly true black background
--   light - light theme with warm background
--   white - pure white background
--
-- Set variant with: vim.g.selenized_variant = "black" (before loading colorscheme)
-- Or rely on vim.o.background for dark/light (uses dark/light variants)

_G.selenized = _G.selenized or {}

local cmd = vim.cmd
local g = vim.g
local fn = vim.fn

-- Determine variant: explicit setting > background-based default
local function get_variant()
  if g.selenized_variant then
    return g.selenized_variant
  end
  return vim.o.background == "light" and "light" or "dark"
end

local none = 'none'
local colors = {
  dark = {
    bg_0       = '#103c48',
    bg_1       = '#184956',
    bg_2       = '#2d5b69',
    bg_15      = '#14404b',
    dim_0      = '#72898f',
    dim_1      = '#90998f',
    fg_0       = '#adbcbc',
    fg_1       = '#cad8d9',
    red        = '#fa5750',
    green      = '#75b938',
    yellow     = '#dbb32d',
    blue       = '#4695f7',
    magenta    = '#f275be',
    cyan       = '#41c7b9',
    orange     = '#ed8649',
    violet     = '#af88eb',
    br_red     = '#ff665c',
    br_green   = '#84c747',
    br_yellow  = '#ebc13d',
    br_blue    = '#58a3ff',
    br_magenta = '#ff84cd',
    br_cyan    = '#53d6c7',
    br_orange  = '#fd9456',
    br_violet  = '#bd96fa',
  },
  black = {
    bg_0       = '#181818',
    bg_1       = '#252525',
    bg_2       = '#3b3b3b',
    bg_15      = '#1e1e1e',
    dim_0      = '#777777',
    dim_1      = '#888888',
    fg_0       = '#b9b9b9',
    fg_1       = '#dedede',
    red        = '#ed4a46',
    green      = '#70b433',
    yellow     = '#dbb32d',
    blue       = '#368aeb',
    magenta    = '#eb6eb7',
    cyan       = '#3fc5b7',
    orange     = '#e67f43',
    violet     = '#a580e2',
    br_red     = '#ff5e56',
    br_green   = '#83c746',
    br_yellow  = '#efc541',
    br_blue    = '#4f9cfe',
    br_magenta = '#ff81ca',
    br_cyan    = '#56d8c9',
    br_orange  = '#fa9153',
    br_violet  = '#b891f5',
  },
  light = {
    bg_0       = '#fbf3db',
    bg_1       = '#ece3cc',
    bg_2       = '#d5cdb6',
    bg_15      = '#f0e8d0',
    dim_0      = '#909995',
    dim_1      = '#909995',
    fg_0       = '#53676d',
    fg_1       = '#3a4d53',
    red        = '#d2212d',
    green      = '#489100',
    yellow     = '#ad8900',
    blue       = '#0072d4',
    magenta    = '#ca4898',
    cyan       = '#009c8f',
    orange     = '#c25d1e',
    violet     = '#8762c6',
    br_red     = '#cc1729',
    br_green   = '#428b00',
    br_yellow  = '#a78300',
    br_blue    = '#006dce',
    br_magenta = '#c44392',
    br_cyan    = '#00978a',
    br_orange  = '#bc5819',
    br_violet  = '#825dc0',
  },
  white = {
    bg_0       = '#ffffff',
    bg_1       = '#ebebeb',
    bg_2       = '#cdcdcd',
    bg_15      = '#f5f5f5',
    dim_0      = '#878787',
    dim_1      = '#878787',
    fg_0       = '#474747',
    fg_1       = '#282828',
    red        = '#d6000c',
    green      = '#1d9700',
    yellow     = '#c49700',
    blue       = '#0064e4',
    magenta    = '#dd0f9d',
    cyan       = '#00ad9c',
    orange     = '#d04a00',
    violet     = '#7f51d6',
    br_red     = '#bf0000',
    br_green   = '#008400',
    br_yellow  = '#af8500',
    br_blue    = '#0054cf',
    br_magenta = '#c7008b',
    br_cyan    = '#009a8a',
    br_orange  = '#ba3700',
    br_violet  = '#6b40c3',
  },
}

local highlight = function(name, val)
  val = val or { fg = 'fg', bg = 'bg' }
  if type(val) == 'string' then
    val = { link = val }
  end
  val.force = true
  val.cterm = val.cterm or {}
  vim.api.nvim_set_hl(0, name, val)
end

local highlights = function(c)
  cmd.hi('clear')
  if fn.exists('syntax_on') then
    cmd.syntax('reset')
  end

  g.colors_name = 'selenized'

  -- Terminal colors
  g.terminal_color_0  = c.bg_1
  g.terminal_color_1  = c.red
  g.terminal_color_2  = c.green
  g.terminal_color_3  = c.yellow
  g.terminal_color_4  = c.blue
  g.terminal_color_5  = c.magenta
  g.terminal_color_6  = c.cyan
  g.terminal_color_7  = c.dim_0
  g.terminal_color_8  = c.bg_2
  g.terminal_color_9  = c.br_red
  g.terminal_color_10 = c.br_green
  g.terminal_color_11 = c.br_yellow
  g.terminal_color_12 = c.br_blue
  g.terminal_color_13 = c.br_magenta
  g.terminal_color_14 = c.br_cyan
  g.terminal_color_15 = c.fg_1

  local hi = {}

  -- Base highlights
  hi['Normal']           = { fg = c.fg_0, bg = c.bg_0 }
  hi['NormalFloat']      = { fg = c.dim_0, bg = c.bg_0 }
  hi['FloatBorder']      = { fg = c.bg_2, bg = none }
  hi['FloatTitle']       = { fg = c.dim_0, bg = c.bg_0 }

  -- Search
  hi['IncSearch']        = { fg = c.orange, bg = none, reverse = true }
  hi['Search']           = { fg = c.yellow, bg = none, reverse = true }
  hi['CurSearch']        = { fg = c.br_yellow, bg = none, reverse = true }
  hi['QuickFixLine']     = 'Search'

  -- Selection & cursor
  hi['Visual']           = { fg = none, bg = c.bg_1 }
  hi['MatchParen']       = { fg = c.br_yellow, bg = c.bg_2, bold = true }
  hi['Cursor']           = { fg = none, bg = none, reverse = true }
  hi['lCursor']          = 'Cursor'
  hi['CursorLine']       = { fg = none, bg = c.bg_1 }
  hi['CursorColumn']     = { fg = none, bg = c.bg_1 }
  hi['ColorColumn']      = { fg = none, bg = c.bg_1 }

  -- Line numbers & columns
  hi['LineNr']           = { fg = c.dim_0, bg = c.bg_1 }
  hi['CursorLineNr']     = { fg = c.fg_1, bg = c.bg_1 }
  hi['SignColumn']       = { fg = none, bg = c.bg_1 }
  hi['FoldColumn']       = { fg = none, bg = c.bg_1 }
  hi['Folded']           = { fg = none, bg = c.bg_1 }

  -- Windows & tabs
  hi['WinSeparator']     = { fg = c.bg_2, bg = none, bold = true }
  hi['StatusLine']       = { fg = none, bg = c.bg_1 }
  hi['StatusLineNC']     = { fg = none, bg = c.bg_2 }
  hi['TabLineSel']       = { fg = c.fg_1, bg = c.bg_2 }
  hi['TabLine']          = { fg = c.fg_0, bg = c.bg_1 }
  hi['TabLineFill']      = { fg = c.fg_0, bg = c.bg_1 }
  hi['WinBar']           = { fg = c.dim_0, bg = c.bg_0 }

  -- Popup menu
  hi['Pmenu']            = { fg = c.dim_0, bg = c.bg_1 }
  hi['PmenuSel']         = { fg = none, bg = c.bg_2 }
  hi['PmenuThumb']       = { fg = none, bg = c.dim_0 }
  hi['PmenuSbar']        = { fg = none, bg = c.bg_2 }

  -- Diff
  hi['DiffAdd']          = { fg = c.green, bg = c.bg_1 }
  hi['DiffChange']       = { fg = none, bg = c.bg_1 }
  hi['DiffDelete']       = { fg = c.red, bg = c.bg_1 }
  hi['DiffText']         = { fg = c.bg_1, bg = c.yellow }
  hi['Added']            = { fg = c.br_green }
  hi['Changed']          = { fg = c.br_blue }
  hi['Removed']          = { fg = c.br_red }

  -- Syntax
  hi['Comment']          = { fg = c.dim_0, bg = none, italic = true }
  hi['Constant']         = { fg = c.cyan, bg = none }
  hi['String']           = 'Constant'
  hi['Number']           = 'Constant'
  hi['Boolean']          = 'Constant'
  hi['Character']        = 'Constant'
  hi['Float']            = 'Constant'
  hi['SpecialChar']      = { fg = c.violet, bg = none }
  hi['Identifier']       = { fg = c.br_blue, bg = none }
  hi['Function']         = 'Identifier'
  hi['Statement']        = { fg = c.br_yellow, bg = none }
  hi['Conditional']      = 'Statement'
  hi['Repeat']           = 'Statement'
  hi['Keyword']          = 'Statement'
  hi['Label']            = 'Statement'
  hi['Exception']        = 'Statement'
  hi['Operator']         = 'Statement'
  hi['PreProc']          = { fg = c.orange, bg = none }
  hi['Define']           = 'PreProc'
  hi['PreCondit']        = 'PreProc'
  hi['Include']          = 'PreProc'
  hi['Macro']            = 'Include'
  hi['Type']             = { fg = c.green, bg = none }
  hi['Typedef']          = 'Type'
  hi['StorageClass']     = 'Type'
  hi['Structure']        = 'Type'
  hi['Special']          = { fg = c.red, bg = none }
  hi['Delimiter']        = 'Special'
  hi['SpecialComment']   = 'Special'
  hi['Debug']            = 'Special'
  hi['Tag']              = 'Special'
  hi['Error']            = { fg = c.red, bg = none, bold = true }
  hi['Todo']             = { fg = c.magenta, bg = none, bold = true }
  hi['Underlined']       = { fg = c.violet, bg = none, underline = true }
  hi['Ignore']           = { fg = c.bg_2, bg = none }

  -- Misc
  hi['Terminal']         = { fg = none, bg = none }
  hi['Conceal']          = { fg = none, bg = none }
  hi['Directory']        = { fg = none, bg = none }
  hi['EndOfBuffer']      = { fg = none, bg = none }
  hi['ErrorMsg']         = { fg = none, bg = none }
  hi['ModeMsg']          = { fg = none, bg = none }
  hi['MoreMsg']          = { fg = none, bg = none }
  hi['NonText']          = { fg = none, bg = none }
  hi['Question']         = { fg = none, bg = none }
  hi['SpecialKey']       = { fg = none, bg = none }
  hi['Title']            = { fg = none, bg = none }
  hi['VisualNOS']        = { fg = none, bg = none }
  hi['WarningMsg']       = { fg = none, bg = none }
  hi['WildMenu']         = { fg = none, bg = none }

  -- Spell
  hi['SpellBad']         = { fg = none, bg = none, sp = c.red, undercurl = true }
  hi['SpellCap']         = { fg = none, bg = none, sp = c.red, undercurl = true }
  hi['SpellLocal']       = { fg = none, bg = none, sp = c.yellow, undercurl = true }
  hi['SpellRare']        = { fg = none, bg = none, sp = c.cyan, undercurl = true }

  -- Suggestions & snippets
  hi['Suggestion']       = { fg = c.dim_1, bg = none, italic = true }
  hi['SnippetTabstop']   = { fg = none, bg = c.bg_1, italic = true }
  hi['CopilotSuggestion'] = 'Suggestion'

  -- Diagnostics
  hi['DiagnosticError']  = { fg = c.red, bg = c.bg_1 }
  hi['DiagnosticWarn']   = { fg = c.yellow, bg = c.bg_1 }
  hi['DiagnosticInfo']   = { fg = c.cyan, bg = c.bg_1 }
  hi['DiagnosticHint']   = { fg = c.violet, bg = c.bg_1 }
  hi['DiagnosticUnderlineError'] = { underline = true, sp = c.red }
  hi['DiagnosticUnderlineWarn']  = { underline = true, sp = c.yellow }
  hi['DiagnosticUnderlineInfo']  = { underline = true, sp = c.cyan }
  hi['DiagnosticUnderlineHint']  = { underline = true, sp = c.violet }

  -- LSP
  hi['LspReferenceText']  = { bg = c.bg_1 }
  hi['LspReferenceRead']  = 'LspReferenceText'
  hi['LspReferenceWrite'] = 'LspReferenceText'
  hi['LspInfoBorder']     = 'FloatBorder'

  -- Git Signs
  hi['GitSignsAdd']      = { fg = c.green, bg = c.bg_1 }
  hi['GitSignsChange']   = { fg = c.blue, bg = c.bg_1 }
  hi['GitSignsDelete']   = { fg = c.red, bg = c.bg_1 }

  -- Treesitter
  hi['@variable']                   = 'Identifier'
  hi['@variable.builtin']           = 'Special'
  hi['@variable.parameter']         = 'Identifier'
  hi['@variable.member']            = 'Identifier'
  hi['@constant']                   = 'Constant'
  hi['@constant.builtin']           = 'Special'
  hi['@constant.macro']             = 'Define'
  hi['@module']                     = 'Identifier'
  hi['@module.builtin']             = 'Special'
  hi['@label']                      = 'Label'
  hi['@string']                     = 'String'
  hi['@string.documentation']       = 'Comment'
  hi['@string.regexp']              = 'SpecialChar'
  hi['@string.escape']              = 'SpecialChar'
  hi['@string.special']             = 'SpecialChar'
  hi['@string.special.symbol']      = 'SpecialChar'
  hi['@string.special.url']         = 'Underlined'
  hi['@string.special.path']        = 'Underlined'
  hi['@character']                  = 'Character'
  hi['@character.special']          = 'SpecialChar'
  hi['@boolean']                    = 'Boolean'
  hi['@number']                     = 'Number'
  hi['@number.float']               = 'Float'
  hi['@type']                       = 'Type'
  hi['@type.builtin']               = 'Special'
  hi['@type.definition']            = 'Typedef'
  hi['@attribute']                  = 'Macro'
  hi['@attribute.builtin']          = 'Special'
  hi['@property']                   = 'Identifier'
  hi['@function']                   = 'Function'
  hi['@function.builtin']           = 'Special'
  hi['@function.call']              = 'Function'
  hi['@function.macro']             = 'Macro'
  hi['@function.method']            = 'Function'
  hi['@function.method.call']       = 'Function'
  hi['@constructor']                = 'Special'
  hi['@operator']                   = 'Operator'
  hi['@keyword']                    = 'Keyword'
  hi['@keyword.coroutine']          = 'Special'
  hi['@keyword.function']           = 'Keyword'
  hi['@keyword.operator']           = 'Operator'
  hi['@keyword.import']             = 'Include'
  hi['@keyword.type']               = 'Keyword'
  hi['@keyword.modifier']           = 'Keyword'
  hi['@keyword.repeat']             = 'Repeat'
  hi['@keyword.return']             = 'Statement'
  hi['@keyword.debug']              = 'Debug'
  hi['@keyword.exception']          = 'Exception'
  hi['@keyword.conditional']        = 'Conditional'
  hi['@keyword.conditional.ternary'] = 'Conditional'
  hi['@keyword.directive']          = 'Define'
  hi['@keyword.directive.define']   = 'Define'
  hi['@punctuation.delimiter']      = 'Delimiter'
  hi['@punctuation.bracket']        = 'Delimiter'
  hi['@punctuation.special']        = 'Special'
  hi['@comment']                    = 'Comment'
  hi['@comment.documentation']      = 'Comment'
  hi['@comment.error']              = { fg = c.bg_0, bg = c.red, bold = true }
  hi['@comment.warning']            = { fg = c.bg_0, bg = c.yellow, bold = true }
  hi['@comment.todo']               = { fg = c.bg_0, bg = c.magenta, bold = true }
  hi['@comment.note']               = { fg = c.bg_0, bg = c.cyan, bold = true }
  hi['@diff.plus']                  = 'Added'
  hi['@diff.minus']                 = 'Removed'
  hi['@diff.delta']                 = 'Changed'
  hi['@tag']                        = 'Tag'
  hi['@tag.builtin']                = 'Special'
  hi['@tag.attribute']              = 'Identifier'
  hi['@tag.delimiter']              = 'Delimiter'
  hi['@markup.heading']             = { fg = c.fg_1, bold = true }
  hi['@markup.link']                = 'Identifier'
  hi['@markup.link.url']            = 'Underlined'
  hi['@markup.underline']           = 'Underlined'
  hi['@markup.raw.block']           = { bg = c.bg_15 }

  -- LSP semantic tokens
  hi['@lsp.type.comment']           = {}
  hi['@lsp.mod.defaultLibrary']     = 'Special'
  hi['@lsp.mod.globalScope']        = { bold = true }
  hi['@lsp.mod.global']             = { bold = true }

  -- nvim-cmp
  hi['CmpItemKindClass']            = 'Type'
  hi['CmpItemKindConstant']         = 'Constant'
  hi['CmpItemKindConstructor']      = 'Type'
  hi['CmpItemKindEnum']             = 'Structure'
  hi['CmpItemKindEnumMember']       = 'Structure'
  hi['CmpItemKindField']            = 'Structure'
  hi['CmpItemKindFile']             = 'Tag'
  hi['CmpItemKindFolder']           = 'Directory'
  hi['CmpItemKindFunction']         = 'Function'
  hi['CmpItemKindInterface']        = 'Structure'
  hi['CmpItemKindKeyword']          = 'Keyword'
  hi['CmpItemKindMethod']           = 'Function'
  hi['CmpItemKindModule']           = 'Structure'
  hi['CmpItemKindOperator']         = 'Operator'
  hi['CmpItemKindProperty']         = 'Structure'
  hi['CmpItemKindSnippet']          = 'Special'
  hi['CmpItemKindStruct']           = 'Structure'
  hi['CmpItemKindText']             = 'Statement'
  hi['CmpItemKindTypeParameter']    = 'Type'
  hi['CmpItemKindVariable']         = 'Delimiter'

  for group, hl_val in pairs(hi) do
    highlight(group, hl_val)
  end

  _G.selenized.colors = c
  _G.selenized.variant = get_variant()
end

-- Apply colorscheme
local variant = get_variant()
_G.selenized.color_scheme = colors
highlights(colors[variant])
