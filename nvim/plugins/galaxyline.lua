local gl = require 'galaxyline'
local condition = require 'galaxyline.condition'
local fileinfo = require 'galaxyline.provider_fileinfo'
gl.short_line_list = {
    'startify', 'undotree', 'fugitive', 'fugitiveblame', 'startuptime',
    'NvimTree', 'vista', 'dbui', 'packer', "dapui_scopes", "dapui_stacks",
       "dapui_watches", "dapui_breakpoints",
}

local cl = {
    bg = '#545862',
    fg = '#c8ccd4',
    normal = '#98c379',
    insert = '#61afef',
    replace = '#e06c75',
    visual = '#e5c07b',
    command = '#d19a66',
    terminal = '#56b6c2',
    lsp_active = '#98c379',
    lsp_inactive = '#e06c75',
    illuminate = {dark = '#3E4B59', mirage = '#3E4B59'},
    yellow = '#DCDCAA',
    dark_yellow = '#D7BA7D',
    cyan = '#4EC9B0',
    green = '#77DD77',
    light_green = '#B5CEA8',
    string_orange = '#CE9178',
    orange = '#FF8800',
    purple = '#C586C0',
    magenta = '#D16D9E',
    grey = '#858585',
    blue = '#569CD6',
    vivid_blue = '#4FC1FF',
    light_blue = '#9CDCFE',
    red = '#FF0000',
    error_red = '#F44747',
    info_yellow = '#FFCC66'
}

local gls = gl.section

local u = function(code)
    if type(code) == 'string' then code = tonumber('0x' .. code) end
    local c = string.char
    if code <= 0x7f then return c(code) end
    local t = {}
    if code <= 0x07ff then
        t[1] = c(bit.bor(0xc0, bit.rshift(code, 6)))
        t[2] = c(bit.bor(0x80, bit.band(code, 0x3f)))
    elseif code <= 0xffff then
        t[1] = c(bit.bor(0xe0, bit.rshift(code, 12)))
        t[2] = c(bit.bor(0x80, bit.band(bit.rshift(code, 6), 0x3f)))
        t[3] = c(bit.bor(0x80, bit.band(code, 0x3f)))
    else
        t[1] = c(bit.bor(0xf0, bit.rshift(code, 18)))
        t[2] = c(bit.bor(0x80, bit.band(bit.rshift(code, 12), 0x3f)))
        t[3] = c(bit.bor(0x80, bit.band(bit.rshift(code, 6), 0x3f)))
        t[4] = c(bit.bor(0x80, bit.band(code, 0x3f)))
    end
    return table.concat(t)
end


local mode_map = {
    ['n'] = {'NORMAL', cl.normal},
    ['i'] = {'INSERT', cl.insert},
    ['R'] = {'REPLACE', cl.replace},
    ['v'] = {'VISUAL', cl.visual},
    ['V'] = {'V-LINE', cl.visual},
    ['c'] = {'COMMAND', cl.command},
    ['s'] = {'SELECT', cl.visual},
    ['S'] = {'S-LINE', cl.visual},
    ['t'] = {'TERMINAL', cl.terminal},
    [''] = {'V-BLOCK', cl.visual},
    [''] = {'S-BLOCK', cl.visual},
    ['Rv'] = {'VIRTUAL'},
    ['rm'] = {'--MORE'},
}

local sep = {
    right_filled = u '2590',
    left_fille = u '258c',
    -- right_filled = u 'e0b2',
    -- left_filled = u 'e0b0',
    right = u '2503',
    left = u '2503',
    -- right = u 'e0b3',
    -- left = u 'e0b1',
}

local icons = {
    locker = u 'f023',
    unsaved = u 'f693',
    dos = u 'e70f',
    unix = u 'f17c',
    mac = u 'f179',
    lsp_warn = u 'f071',
    lsp_error = u 'f46e',
}

local function mode_label() return mode_map[vim.fn.mode()][1] or 'N/A' end
local function mode_hl() return mode_map[vim.fn.mode()][2] or cl.none end

local function highlight(group, fg, bg, gui)
    local cmd = string.format('highlight %s guifg=%s guibg=%s', group, fg, bg)
    if gui ~= nil then cmd = cmd .. ' gui=' .. gui end
    vim.cmd(cmd)
end

local function buffer_not_empty()
    if vim.fn.empty(vim.fn.expand '%:t') ~= 1 then return true end
    return false
end

local function wide_enough()
    local squeeze_width = vim.fn.winwidth(0)
    if squeeze_width > 80 then return true end
    return false
end

gls.left = {
    {
        ViMode = {
            provider = function()
                local modehl = mode_hl()
                highlight('GalaxyViMode', cl.bg, modehl, 'bold')
                highlight('GalaxyViModeInv', modehl, cl.bg, 'bold')
                return string.format('  %s ', mode_label())
            end,
            separator = sep.left_filled,
            separator_highlight = 'GalaxyViModeInv',
        },
    },
    {
        FileName = {
            provider = function()
                if not buffer_not_empty() then return '' end
                local fname
                if wide_enough() then
                    fname = vim.fn.fnamemodify(vim.fn.expand '%', ':~:.')
                else
                    fname = vim.fn.expand '%:t'
                end
                if #fname == 0 then return '' end
                if vim.bo.readonly then
                    fname = fname .. ' ' .. icons.locker
                end
                if vim.bo.modified then
                    fname = fname .. ' ' .. icons.unsaved
                end
                return '  ' .. fname .. ' '
            end,
            highlight = {cl.fg, cl.bg},
            separator = sep.left,
            separator_highlight = 'GalaxyViModeInv',
        },
    },
    {
    GitBranch = {
            provider = {
                function()
                    return '  '
                end,
                'GitBranch',
                function()
                    return ' '
                end,
            },
            condition = condition.check_git_workspace,
            highlight = {cl.fg, cl.bg},
            separator = sep.left,
            separator_highlight = 'GalaxyViModeInv',
        },
    },
    {
    DiffAdd = {
        provider = 'DiffAdd',
        condition = condition.hide_in_width,
        icon = '  ',
        highlight = {cl.green, cl.bg}
    }
    },
    {
    DiffModified = {
        provider = 'DiffModified',
        condition = condition.hide_in_width,
        icon = ' 柳',
        highlight = {cl.vivid_blue, cl.bg}
    }
    },
    {
    DiffRemove = {
        provider = 'DiffRemove',
        condition = condition.hide_in_width,
        icon = '  ',
        highlight = {cl.red, cl.bg},
        separator = sep.right,
        separator_highlight = 'GalaxyViModeInv',
    }
    },
    {
    Vista = {
        provider = 'VistaPlugin',
        highlight = {cl.fg, cl.bg},
        },
    },
}


gls.right = {
    {
    ShowLspClient = {
            provider = 'GetLspClient',
            condition = function()
                local tbl = {['dashboard'] = true, [' '] = true}
                if tbl[vim.bo.filetype] then return false end
                return true
            end,
            highlight = {cl.fg, cl.bg},
            separator = sep.left,
            separator_highlight = 'GalaxyViModeInv',
        }
     },
    {
    whitespace = {
            provider = function () return ' ' end,
            highlight = {cl.fg, cl.bg},
        }
     },
     {
        -- DiagnosticWarn = {
        --     provider = function()
        --         local n = vim.lsp.diagnostic.get_count(0, 'Warning')
        --         if n == 0 then return '' end
        --         return string.format(' %s %d ', icons.lsp_warn, n)
        --     end,
        --     highlight = {'yellow', cl.bg},
        -- },
        -- DiagnosticError = {
        --     provider = function()
        --         local n = vim.lsp.diagnostic.get_count(0, 'Error')
        --         if n == 0 then return '' end
        --         return string.format(' %s %d ', icons.lsp_error, n)
        --     end,
        --     highlight = {'red', cl.bg},
        -- },
        -- DiagnosticHint = {
        --     provider = function()
        --         local n = vim.lsp.diagnostic.get_count(0, 'Hint')
        --         if n == 0 then return '' end
        --         return string.format('  %s %d ', icons.lsp_error, n)
        --     end,
        --     highlight = {cl.vivid_blue, cl.bg},
        -- },
        DiagnosticInfo = {
            provider = 'DiagnosticInfo',
            highlight = {cl.fg, cl.bg},
        },
    }, {
        FileType = {
            provider = function()
                if not buffer_not_empty() then return '' end
                local icon = icons[vim.bo.fileformat] or ''
                return string.format(' %s %s ', icon, vim.bo.filetype)
            end,
            condition = buffer_not_empty,
            highlight = {cl.fg, cl.bg},
            separator = sep.right,
            separator_highlight = 'GalaxyViModeInv',
        },
    }, {
        PositionInfo = {
            provider = {
                function()
                    return string.format(
                      '%s:%s', vim.fn.line('.'), vim.fn.col('.')
                    )
                end,
            },
            highlight = 'GalaxyViMode',
            condition = buffer_not_empty,
            separator = sep.right_filled,
            separator_highlight = 'GalaxyViModeInv',
        },
        PercentInfo = {
            provider = fileinfo.current_line_percent,
            highlight = 'GalaxyViMode',
            condition = buffer_not_empty,
            separator = sep.right,
            separator_highlight = 'GalaxyViMode',
        },
    },
}

for k, v in pairs(gls.left) do gls.short_line_left[k] = v end
table.remove(gls.short_line_left, 1)

for k, v in pairs(gls.right) do gls.short_line_right[k] = v end
table.remove(gls.short_line_right)
