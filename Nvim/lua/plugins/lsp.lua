return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd" }, -- Garante a instalação do clangd pelo Mason
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.lsp.config('clangd', {
        cmd = { "clangd", "--background-index", "--clang-tidy" },
      })
      
      vim.lsp.enable('clangd')

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)     -- Ir para a definição do método/variável
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)           -- Exibir documentação em janela flutuante
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Renomear símbolo de forma segura
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Chamar ações/correções rápidas do compilador
        end,
      })
    end,
  },
}
