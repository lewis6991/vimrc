--- @param path string
--- @param markers string[]
--- @return string?
local function find_root(path, markers)
  local match = vim.fs.find(markers, { path = path, upward = true })[1]
  if not match then
    return
  end
  local stat = vim.uv.fs_stat(match)
  local isdir = stat and stat.type == "directory"
  return vim.fn.fnamemodify(match, isdir and ':p:h:h' or ':p:h')
end

local lsp_group = vim.api.nvim_create_augroup('lewis6991.lsp', {})

local function setup_cmp(config)
  config.capabilities = vim.lsp.protocol.make_client_capabilities()
  vim.tbl_extend('force', config.capabilities, require('cmp_nvim_lsp').default_capabilities())
end

local function setup(config)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = config.filetype,
    group = lsp_group,
    callback = function(args)
      local exe = config.cmd[1]
      if vim.fn.executable(exe) ~= 1 then
        vim.notify(string.format("Cannot start %s: '%s' not in PATH", config.name, exe), vim.log.levels.ERROR)
        return true
      end

      setup_cmp(config)

      config.capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      config.markers = config.markers or {}
      table.insert(config.markers, '.git')
      config.root_dir = find_root(args.file, config.markers)

      -- buffer could have switched due to schedule_wrap so need to run buf_call
      vim.lsp.start(config, { bufnr = args.buf })
    end
  })
end

setup {
  filetype = 'c',
  cmd = { 'clangd' },
  markers = { 'compile_commands.json' },
}

local function add_settings(client, settings)
  local config = client.config
  config.settings = vim.tbl_deep_extend('force', config.settings, settings)
  client.notify("workspace/didChangeConfiguration", { settings = config.settings })
end

setup {
  name = 'luals',
  filetype = 'lua',
  cmd = { 'lua-language-server' },
  markers = { '.luarc.json' },
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.uv.fs_stat(path..'/.luarc.json') and not vim.uv.fs_stat(path..'/.luarc.jsonc') then
      add_settings(client, {
        Lua = {
          runtime = {
            version = 'LuaJIT'
          },
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME,
              "${3rd}/busted/library",
              "${3rd}/luv/library"
            }
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        }
      })
    end
    return true
  end,
  settings = {
    Lua = {
      hint = {
        enable = true,
        paramName = 'Literal',
        setType = true
      }
    }
  }
}

setup {
  name = 'pyright',
  cmd = { 'pyright-langserver', '--stdio' },
  filetype = 'python',
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
      },
    },
  },
}

setup {
  name = 'bashls',
  cmd = { 'bash-language-server', 'start' },
  filetype = 'sh',
}

--- npm i -g vscode-langservers-extracted
setup {
  name = 'jsonls',
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetype = { 'json', 'jsonc' },
  install = {'npm', 'i', '-g', 'vscode-langservers-extracted' }
}

-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(args)
--     local bufnr = args.buf
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     client.server_capabilities.semanticTokensProvider = nil
--   end
-- })
