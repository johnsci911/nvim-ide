local gl = require('galaxyline')
local utils = require('config.galaxyline-utils')

local gls = gl.section
gl.short_line_list = { 'defx', 'packager', 'vista', 'NvimTree' }

-- Colors
local colors = {
  bg = '#24283B',
  fg = '#f8f8f2',
  section_bg = '#3B4261',
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
    n = colors.cyan,
    i = colors.green,
    c = colors.orange,
    V = colors.magenta,
    [''] = colors.magenta,
    v = colors.magenta,
    R = colors.red,
  }

  return mode_colors[vim.fn.mode()]
end

-- Left side
gls.left[1] = {
  FirstElement = {
    provider = function() return ' ' end,
    highlight = { colors.cyan, colors.bg }
  },
}
gls.left[2] = {
  ViMode = {
    provider = function()
      local alias = {
        n = 'NORMAL',
        i = 'INSERT',
        c = 'COMMAND',
        V = 'VISUAL',
        [''] = 'VISUAL',
        v = 'VISUAL',
        R = 'REPLACE',
      }
      vim.api.nvim_command('hi GalaxyViMode guifg='..mode_color())
      return alias[vim.fn.mode()]..' '
    end,
    highlight = { colors.bg, colors.bg },
    separator = " ",
    separator_highlight = {colors.section_bg, colors.bg},
  },
}
gls.left[3] = {
  firstLeftElement = {
    provider = function() return ' ' end,
    highlight = { colors.cyan, colors.section_bg },
  },
}
gls.left[4] ={
  FileIcon = {
    provider = 'FileIcon',
    condition = buffer_not_empty,
    highlight = { require('galaxyline.provider_fileinfo').get_file_icon_color, colors.section_bg },
  },
}
gls.left[5] = {
  FileName = {
    provider = 'FileName',
    condition = buffer_not_empty,
    highlight = { colors.fg, colors.section_bg },
    separator = " ",
    separator_highlight = {colors.section_bg, colors.bg},
  }
}
gls.left[6] = {
  GitIcon = {
    provider = function() return '  ' end,
    condition = buffer_not_empty,
    highlight = {colors.red,colors.bg},
  }
}
gls.left[7] = {
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
	  return "Editing..."
    end,
    condition = buffer_not_empty,
    highlight = {colors.fg,colors.bg},
  }
}
gls.left[8] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.green, colors.bg },
  }
}
gls.left[9] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.orange, colors.bg },
  }
}
gls.left[10] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = checkwidth,
    icon = ' ',
    highlight = { colors.red,colors.bg }
  }
}
gls.left[11] = {
  LeftEnd = {
    provider = function() return ' ' end,
    condition = buffer_not_empty,
    highlight = {colors.section_bg,colors.bg}
  }
}
gls.left[12] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '   ',
    highlight = {colors.red,colors.section_bg}
  }
}
gls.left[13] = {
  Space = {
    provider = function () return ' ' end,
    highlight = {colors.section_bg,colors.section_bg},
  }
}
gls.left[14] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.orange,colors.section_bg},
  }
}
gls.left[15] = {
  Space = {
    provider = function () return ' ' end,
    highlight = {colors.section_bg,colors.section_bg},
  }
}
gls.left[16] = {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    highlight = {colors.blue,colors.section_bg},
    separator = ' ',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

-- Right side
gls.right[1] = {
  firstRightElement = {
    provider = function() return ' ' end,
    highlight = { colors.cyan, colors.section_bg },
    separator = ' ',
    separator_highlight = { colors.section_bg,colors.bg },
  },
}

gls.right[2]= {
  FileFormat = {
    provider = function() return vim.bo.filetype end,
    highlight = { colors.fg,colors.section_bg },
  }
}
gls.right[3] = {
  LineInfo = {
    provider = 'LineColumn',
    highlight = { colors.fg, colors.section_bg },
    separator = ' | ',
    separator_highlight = { colors.bg, colors.section_bg },
  },
}

gls.right[4] = {
    ShowLspClient = {
        provider = 'GetLspClient',
        condition = function()
            local tbl = {['dashboard'] = true, [' '] = true}
            if tbl[vim.bo.filetype] then return false end
            return true
        end,
        highlight = {colors.blue,colors.section_bg},
		separator = '| ',
		separator_highlight = { colors.bg, colors.section_bg },
    }
}

gls.right[5] = {
  Percent = {
    provider = 'LinePercent',
    highlight = { colors.fg, colors.bg },
    separator = ' ',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

gls.right[6] = {
  ScrollBar = {
    provider = 'ScrollBar',
    highlight = { colors.blue, colors.section_bg },
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

gls.right[7] = {
  lastElement = {
    provider = function() return ' ' end,
    highlight = { colors.cyan, colors.bg }
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
    separator = ' ',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

gls.short_line_right[1] = {
  BufferIcon = {
    provider= 'BufferIcon',
    highlight = { colors.yellow, colors.section_bg },
    separator = ' ',
    separator_highlight = { colors.section_bg, colors.bg },
  }
}

gls.short_line_right[2] = {
  shortLastElement = {
    provider = function() return ' ' end,
    highlight = { colors.section_bg, colors.section_bg },
  }
}
-- Force manual load so that nvim boots with a status line
gl.load_galaxyline()
