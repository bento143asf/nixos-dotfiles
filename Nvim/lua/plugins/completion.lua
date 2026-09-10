return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- Traz as sugestões do seu Clangd (C)
      "hrsh7th/cmp-buffer",       -- Sugere palavras escritas no arquivo aberto
      "hrsh7th/cmp-path",         -- Sugere caminhos de diretórios/arquivos
      "L3MON4D3/LuaSnip",         -- Motor de snippets obrigatório
      "saadparwaiz1/cmp_luasnip", -- Conecta os snippets ao menu visual
      "rafamadriz/friendly-snippets", -- Adiciona centenas de templates de código prontos
    },
    config = function()
      local cmp = require("cmp")
      
      -- Carrega os snippets prontos do friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(), -- Força abrir o menu flutuante
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- 'Enter' aceita a sugestão
          ["<Tab>"] = cmp.mapping.select_next_item(), -- Move para baixo na lista
          ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Move para cima na lista
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- Prioridade 1: Sugestões inteligentes do compilador C
          { name = "luasnip" },  -- Prioridade 2: Modelos prontos de código
          { name = "buffer" },   -- Prioridade 3: Palavras comuns do texto
          { name = "path" },     -- Prioridade 4: Arquivos locais
        }),
      })
    end,
  },
}
