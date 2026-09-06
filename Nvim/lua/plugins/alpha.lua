-- lua/plugins/alpha.lua

return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function ()
    local alpha = require('alpha')
    local dashboard = require('alpha.themes.dashboard')

    -- 1. HEADER ("NEOVIM" Logo in ANSI Shadow)
    dashboard.section.header.val = {
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
    }
    dashboard.section.header.opts.hl = "Keyword"

    -- Função customizada para pedir o nome do arquivo antes de criar
    local function create_new_file()
        vim.ui.input({ prompt = "📄 Enter file name: " }, function(input)
            if input == nil or input == "" then
                return 
            end
            vim.cmd("edit " .. input)
            vim.cmd("startinsert")
        end)
    end

    -- Função interna para criar botões limpos e sem as barras ou letras laterais
    local function menu_button(icon, text, action)
        return {
            type = "button",
            val = string.format("    %s   %-30s  ", icon, text),
            on_press = function()
                if type(action) == "string" then vim.cmd(action) else action() end
            end,
            opts = {
                position = "center",
                width = 38,
                cursor = 5,
                shortcut = "", -- Sem letras de atalho poluindo a lateral
                hl = "Normal",
                hl_shortcut = "Normal",
            },
        }
    end

    -- 2. BOTÕES COM LINHA SUPERIOR E INFERIOR (Sem as laterais)
    dashboard.section.buttons.val = {
        { type = "text", val = "────────────────────────────────────────", opts = { position = "center", hl = "Comment" } },
        { type = "padding", val = 1 }, 
        menu_button("🔍", "Find File", "Telescope find_files"),
        menu_button("📄", "New File", create_new_file),
        menu_button("🔌", "Manage Plugins (Lazy)", "Lazy"),
        menu_button("❌", "Quit", "qa"),
        { type = "padding", val = 1 }, 
        { type = "text", val = "────────────────────────────────────────", opts = { position = "center", hl = "Comment" } },
    }

    -- 3. FOOTER PERSONALIZADO (Plugins + Assinatura em Itálico com 8 espaços de recuo)
    local stats = require("lazy").stats()
    
    -- Cria o grupo de destaque para o cinza discreto e itálico da assinatura
    vim.api.nvim_set_hl(0, "AlphaSignature", { fg = "#6C7485", italic = true })

    -- Componente da mensagem de plugins carregados
    local plugins_loaded = {
        type = "text",
        val = "⚡ " .. stats.count .. " plugins loaded",
        opts = { position = "center", hl = "Comment" }
    }

    -- Componente da assinatura com 8 espaços antes do texto
    local signature = {
        type = "text",
        val = "    by 143.",
        opts = { position = "center", hl = "AlphaSignature" }
    }

    -- 4. ORGANIZAÇÃO DO LAYOUT VERTICAL
    dashboard.config.layout = {
        { type = "padding", val = 4 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 2 },
        plugins_loaded,                 -- Linha dos plugins
        { type = "padding", val = 1 },  -- Pequeno espaço entre os dois textos
        signature,                      -- Linha da assinatura em itálico
    }

    alpha.setup(dashboard.config)
  end
}
