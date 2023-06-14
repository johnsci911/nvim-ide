local gl = require('galaxyline')
local utils = require('config.galaxyline-utils')

local macchiato = require("catppuccin.palettes").get_palette "macchiato"

local gls = gl.section
gl.short_line_list = {
  'defx',
  'packager',
  'vista',
  'NvimTree',
  'DiffviewFiles',
  'ctrlsf',
  'floaterm',
}

-- Colors
local colors = {
  -- Macchiato
  bg         = macchiato.base,
  fg         = macchiato.text,
  section_bg = macchiato.surface0,

  -- Nord
  -- bg         = '#2E3440',
  -- fg         = '#f8f8f2',
  -- section_bg = '#3B4252',

  yellow = '#f1fa8c',
  cyan = '#8be9fd',
  green = '#50fa7b',
  orange = '#ffb86c',
  magenta = '#ff79c6',
  blue = '#8be9fd',
  red = '#ff5555'
}

-- Local helper functions
local buffer_not_empty = function()
  return not utils.is_buffer_empty()
end

local checkwidth = function()
  return utils.has_width_gt(40) and buffer_not_empty()
end

local mode_color = function()
  local mode_colors = {
    n      = colors.cyan,
    i      = colors.green,
    c      = colors.orange,
    V      = colors.magenta,
    [''] = colors.magenta,
    v      = colors.magenta,
    R      = colors.red,
    t      = colors.green,
  }

  return mode_colors[vim.fn.mode()]
end

-- Left side
gls.left[1] = {
  FirstElement = {
    provider = function() return ' ' end,
    highlight = { colors.bg, colors.bg }
  },
}
gls.left[2] = {
  ViMode = {
    provider = function()
      local alias = {
        n      = 'NORMAL',
        i      = 'INSERT',
        c      = 'COMMAND',
        V      = 'VISUAL',
        [''] = 'VISUAL',
        v      = 'VISUAL',
        R      = 'REPLACE',
        t      = 'TERMINAL',
      }
      vim.api.nvim_command('hi GalaxyViMode guifg=' .. mode_color())
      return alias[vim.fn.mode()]..' '
    end,
    highlight = { colors.bg, colors.bg },
    separator = "",
    condition = buffer_not_empty,
    separator_highlight = {colors.section_bg, colors.bg},
  },
}
gls.left[3] = {
  firstLeftElement = {
    provider = function() return ' ' end,
    condition = buffer_not_empty,
    highlight = { colors.cyan, colors.section_bg },
  },
}
gls.left[4] ={
  GitIcon = {
    provider = function() return '  ' end,
    condition = buffer_not_empty,
    highlight = { colors.red, colors.section_bg },
  },
}
gls.left[5] = {
  GitBranch = {
    provider = function()
      local vcs = require('galaxyline.provider_vcs')
      local branch_name = vcs.get_git_branch()
      if (branch_name) then
        if (string.len(branch_name) > 28) then
          return string.sub(branch_name, 1, 25).."..."
        end
        return branch_name.." "
      else
        return "Not a Repo"
      end
    end,
    condition = buffer_not_empty,
    highlight = { colors.fg, colors.section_bg },
  }
}
gls.left[6] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = checkwidth,
    icon = ' ',
    highlight = {colors.green,colors.section_bg},
  }
}
gls.left[7] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.orange, colors.section_bg },
  }
}
gls.left[8] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.red,colors.section_bg }
  }
}
gls.left[9] = {
  LeftEnd = {
    provider = function() return ' ' end,
    condition = buffer_not_empty,
    highlight = {colors.section_bg,colors.bg}
  }
}
gls.left[10] = {
  Space = {
    provider = function () return ' ' end,
    highlight = {colors.section_bg,colors.bg},
  }
}
gls.left[11] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '   ',
    highlight = {colors.red,colors.bg}
  }
}
gls.left[12] = {
  Space = {
    provider = function () return ' ' end,
    highlight = {colors.section_bg,colors.bg},
  }
}
gls.left[13] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.orange,colors.bg},
  }
}
gls.left[14] = {
  Space = {
    provider = function () return ' ' end,
    highlight = {colors.section_bg,colors.bg},
  }
}
gls.left[15] = {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    highlight = {colors.blue,colors.bg},
  }
}

-- Right side
gls.right[1] = {
  firstRightElement = {
    provider = function() return ' ' end,
    highlight = { colors.cyan, colors.section_bg },
    separator = '' ,
    separator_highlight = { colors.section_bg,colors.bg },
  },
}

gls.right[2] = {
  FileEncode = {
    provider = 'FileEncode',
    highlight = { colors.fg, colors.section_bg },
    condition = checkwidth,
  },
}

gls.right[3]= {
  FileFormat = {
    provider = function() return vim.bo.filetype end,
    highlight = { colors.fg,colors.section_bg },
    separator = ' | ',
    separator_highlight = { colors.bg, colors.section_bg },
    condition = checkwidth,
  }
}

gls.right[4] = {
  SpaceBeforeLineColumn = {
    provider = function() return '  | ' end,
    condition = checkwidth,
    highlight = { colors.bg, colors.section_bg },
  },
}

gls.right[5] = {
  LineInfo = {
    provider = 'LineColumn',
    highlight = { colors.fg, colors.section_bg },
    separator_highlight = { colors.bg, colors.section_bg },
  },
}

gls.right[6] = {
  Percent = {
    provider = 'LinePercent',
    highlight = { colors.fg, colors.section_bg },
    separator = '|',
    separator_highlight = { colors.bg, colors.section_bg },
  }
}

gls.right[7] = {
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = function()
        local tbl = {['dashboard'] = true}
        if tbl[vim.bo.filetype] then return false end
        return true
    end and checkwidth,
    highlight = {colors.blue,colors.bg},
    separator = ' ',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

gls.right[8] = {
  SpaceAfterLSPClient = {
    provider = function() return ' ' end,
    condition = buffer_not_empty and checkwidth,
    highlight = { colors.fg, colors.bg },
  },
}

-- Short status line
gls.short_line_left[1] = {
  shortFirstElement = {
    provider = function() return ' ' end,
    highlight = { colors.section_bg, colors.section_bg },
  },
}

gls.short_line_left[2] = {
  BufferType = {
    provider = 'FileTypeName',
    highlight = { colors.fg, colors.section_bg },
    separator = '',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

gls.short_line_right[1] = {
  BufferIcon = {
    provider= 'BufferIcon',
    highlight = { colors.yellow, colors.bg },
  }
}

-- Force manual load so that nvim boots with a status line
gl.load_galaxyline()
