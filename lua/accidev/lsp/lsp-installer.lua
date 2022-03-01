local lsp_installer = require "nvim-lsp-installer"

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
	local opts = {
		on_attach = require("accidev.lsp.handlers").on_attach,
		capabilities = require("accidev.lsp.handlers").capabilities,
	}


  if server.name == 'rust_analyzer' then
    local rust_opts = {
      standalone = false,
      checkOnSave = {
        command = "clippy"
      },
      random_thing = false
    }
    require("rust-tools").setup {
      server = vim.tbl_deep_extend("force", server:get_default_options(), opts, {
        settings = {
          ['rust-analyzer'] = rust_opts,
        }
      }),
    }
    server:attach_buffers()
  else
    local status_ok, lsp_opts = pcall(require, "accidev.lsp.settings." .. server.name)
    if status_ok then
      opts = vim.tbl_deep_extend("force", lsp_opts, opts)
    else
      vim.notify('error loading lsp settings: ' .. server.name, vim.log.levels.WARN)
    end

    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(opts)
  end
end)

