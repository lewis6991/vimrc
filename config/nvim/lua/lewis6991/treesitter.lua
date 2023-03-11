require'nvim-treesitter'.define_modules {
  fold = {
    attach = function()
      vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.opt_local.foldmethod = 'expr'
      vim.cmd.normal'zx' -- recompute folds
    end,
    detach = function() end,
  }
}

require'treesitter-context'.setup {
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
  trim_scope = 'outer',
  patterns = {
    tcl = {
      'procedure',
      'conditional',
      'while',
      'foreach',
      'namespace',
    },
  }
}

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    if pcall(vim.treesitter.get_parser) then
      vim.treesitter.start()
    end
  end
})

require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "c",
    "help",
    "html",
    "json",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "python",
    "rst",
    "teal",
  },
  indent = {
    enable = true,
    is_supported = function(lang)
      return ({
        lua = true,
        c = true,
        tcl = true
      })[lang] or false
    end
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection    = "gnn",
      node_incremental  = "grn",
      scope_incremental = "grc",
      node_decremental  = "grm",
    },
  },
  fold = {
    enable = true,
    disable = {'rst', 'make'}
  },
  context_commentstring = { enable = true },
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
local c_info = parser_config.c.install_info
-- url = 'https://github.com/nvim-treesitter/tree-sitter-c',
c_info.url = '~/projects/tree-sitter-c'
c_info.revision = 'nvimc'
