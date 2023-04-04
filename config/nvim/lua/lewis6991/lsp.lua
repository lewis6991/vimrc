local function setup(server, settings)
  require'lspconfig'[server].setup{
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    settings = settings
  }
end

require("neodev").setup()

setup('clangd')
-- setup('cmake')

setup('lua_ls', {
  Lua = {
    diagnostics = {
      groupSeverity = {
        strong = 'Warning',
        strict = 'Warning',
      },
      groupFileStatus = {
        ["ambiguity"]  = "Opened",
        ["await"]      = "Opened",
        ["codestyle"]  = "None",
        ["duplicate"]  = "Opened",
        ["global"]     = "Opened",
        ["luadoc"]     = "Opened",
        ["redefined"]  = "Opened",
        ["strict"]     = "Opened",
        ["strong"]     = "Opened",
        ["type-check"] = "Opened",
        ["unbalanced"] = "Opened",
        ["unused"]     = "Opened",
      },
      unusedLocalExclude = { '_*' },
      globals = {
        'it',
        'describe',
        'before_each',
        'after_each',
        'pending'
      }
    },
  }
})

setup('pyright')
setup('bashls')
-- setup('teal_ls')
setup('rust_analyzer')
