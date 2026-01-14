-- Lualine theme for selenized (all variants)
-- Uses colors set by the selenized colorscheme
local colors = selenized.colors
return {
  normal = {
    a = { fg = colors.bg_1, bg = colors.blue },
    b = { fg = colors.cyan, bg = colors.bg_2 },
    c = { fg = colors.dim_0, bg = colors.bg_1 },
  },
  insert = { a = { fg = colors.bg_1, bg = colors.green } },
  visual = { a = { fg = colors.bg_1, bg = colors.magenta } },
  replace = { a = { fg = colors.bg_1, bg = colors.red } },
  inactive = {
    a = { fg = colors.dim_0, bg = colors.bg_1 },
    b = { fg = colors.dim_0, bg = colors.bg_1 },
    c = { fg = colors.dim_0, bg = colors.bg_1 },
  },
}
