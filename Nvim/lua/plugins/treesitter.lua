return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")
        local languages = { "lua", "c", "php", "query" }
        ts.setup({
            install_dir = vim.fs.normalize(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter"),
        })
        vim.opt.runtimepath:append(vim.fs.normalize(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter"))
        ts.install(languages)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = languages,
            callback = function()
                vim.treesitter.start()
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
