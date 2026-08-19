-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- General options
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.o.guifont = "JetBrainsMono Nerd Font:h14"
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.confirm = true

-- Shell según el sistema operativo
if vim.fn.has("win32") == 1 then
    vim.opt.shell = "pwsh"
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
    vim.opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.opt.shellpipe = "2>&1 | Tee-Object %s; exit $LastExitCode"
elseif vim.fn.has("unix") == 1 then
    vim.opt.shell = "bash"
    vim.opt.shellcmdflag = "-c"
end

-- Indentación
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Límite visual
-- vim.opt.colorcolumn = "80"
vim.opt.textwidth = 80

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- Plugins
        {
            "ibhagwan/fzf-lua",
            -- optional for icon support
            dependencies = { "nvim-tree/nvim-web-devicons" },
            ---@module "fzf-lua"
            ---@type fzf-lua.Config|{}
            ---@diagnostic disable: missing-fields
            opts = {},
            ---@diagnostic enable: missing-fields
        },
        {
            "stevearc/oil.nvim",
            lazy = false,
            dependencies = { "nvim-tree/nvim-web-devicons" },
            opts = {
                default_file_explorer = true,
                columns = { "icon" },
            },
        },
        {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = function()
                require("lualine").setup({
                    options = {
                        theme = "auto",
                        section_separators = "",
                        component_separators = "",
                    },
                    sections = {
                        lualine_x = {},
                    },
                })
            end,
        },
        {
            "williamboman/mason.nvim",
            config = function()
                require("mason").setup()
            end,
        },

        {
            "williamboman/mason-lspconfig.nvim",
            dependencies = { "mason.nvim" },
            config = function()
                require("mason-lspconfig").setup({
                    ensure_installed = { "lua_ls", "ts_ls", "pyright", "clangd", "jdtls" },
                    automatic_enable = false,
                })
            end,
        },
        {
            "neovim/nvim-lspconfig",
            dependencies = {
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",
            },
            config = function()
                local capabilities = require("cmp_nvim_lsp").default_capabilities()
                local servers = { "lua_ls", "ts_ls", "pyright", "clangd", "jdtls" }
                for _, server in ipairs(servers) do
                    vim.lsp.config(server, { capabilities = capabilities })
                    vim.lsp.enable(server)
                end

                -- Keymaps
                vim.keymap.set("n", "gd", vim.lsp.buf.definition)
                vim.keymap.set("n", "K", vim.lsp.buf.hover)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
            end,
        },
        {
            "stevearc/conform.nvim",
            event = "BufWritePre", -- carga antes de guardar
            config = function()
                require("conform").setup({
                    formatters_by_ft = {
                        lua = { "stylua" },
                        javascript = { "prettier" },
                        typescript = { "prettier" },
                        python = { "black" },
                    },

                    -- formatear al guardar
                    format_on_save = {
                        timeout_ms = 500,
                        lsp_format = "fallback",
                    },
                })
            end,
        },
        {
            "rose-pine/neovim",
            name = "rose-pine",
            lazy = false,
            priority = 1000,
            config = function()
                require("rose-pine").setup({
                    variant = "main",
                    dark_variant = "main",
                    styles = {
                        bold = false,
                        italic = true,
                        transparency = false,
                    },
                    highlight_groups = {
                        Comment = { fg = "muted", italic = true },
                        Identifier = { fg = "text" },
                        Function = { fg = "text" },
                        Operator = { fg = "subtle" },
                        Keyword = { fg = "iris", bold = true },
                        Type = { fg = "foam" },
                        String = { fg = "gold" },
                        Constant = { fg = "gold" },

                        ["@variable"] = { fg = "text" },
                        ["@variable.member"] = { fg = "text" },
                        ["@variable.parameter"] = { fg = "text" },
                        ["@property"] = { fg = "text" },
                        ["@function"] = { fg = "text" },
                        ["@function.call"] = { fg = "text" },
                        ["@function.method"] = { fg = "text" },
                        ["@function.method.call"] = { fg = "text" },
                        ["@module"] = { fg = "text" },
                        ["@operator"] = { fg = "subtle" },
                        ["@punctuation"] = { fg = "subtle" },
                        ["@keyword"] = { fg = "iris", bold = true },
                        ["@type"] = { fg = "foam" },
                        ["@string"] = { fg = "gold" },
                        ["@constant"] = { fg = "gold" },
                        ["@number"] = { fg = "gold" },
                        ["@boolean"] = { fg = "gold" },
                        ["@comment"] = { fg = "muted", italic = true },

                        ["@lsp.type.variable"] = { fg = "text" },
                        ["@lsp.type.parameter"] = { fg = "text" },
                        ["@lsp.type.property"] = { fg = "text" },
                        ["@lsp.type.function"] = { fg = "text" },
                        ["@lsp.type.method"] = { fg = "text" },
                        ["@lsp.type.class"] = { fg = "foam" },
                        ["@lsp.type.interface"] = { fg = "foam" },
                        ["@lsp.type.type"] = { fg = "foam" },
                    },
                })
                vim.cmd.colorscheme("rose-pine")
            end,
        },
        {
            "goolord/alpha-nvim",
            event = "VimEnter",
            config = function()
                local alpha = require("alpha")
                local dashboard = require("alpha.themes.dashboard")

                dashboard.section.header.val = {
                    " ███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓",
                    " ██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒",
                    "▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░",
                    "▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██ ",
                    "▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██▒   ░██▒",
                    "░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░  ░",
                    "░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░",
                    "   ░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░      ░   ",
                    "         ░    ░  ░    ░ ░        ░   ░         ░   ",
                    "                                                   ",
                    "                                                   ",
                    "                                                   ",
                    "                                                   ",
                    "                                                   ",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣤⣤⣤⡼⠀⢀⡀⣀⢱⡄⡀⠀⠀⠀⢲⣤⣤⣤⣤⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣾⣿⣿⣿⣿⣿⡿⠛⠋⠁⣤⣿⣿⣿⣧⣷⠀⠀⠘⠉⠛⢻⣷⣿⣽⣿⣿⣷⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⢀⣴⣞⣽⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠠⣿⣿⡟⢻⣿⣿⣇⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣟⢦⡀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⣠⣿⡾⣿⣿⣿⣿⣿⠿⣻⣿⣿⡀⠀⠀⠀⢻⣿⣷⡀⠻⣧⣿⠆⠀⠀⠀⠀⣿⣿⣿⡻⣿⣿⣿⣿⣿⠿⣽⣦⡀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⣼⠟⣩⣾⣿⣿⣿⢟⣵⣾⣿⣿⣿⣧⠀⠀⠀⠈⠿⣿⣿⣷⣈⠁⠀⠀⠀⠀⣰⣿⣿⣿⣿⣮⣟⢯⣿⣿⣷⣬⡻⣷⡄⠀⠀⠀",
                    "⠀⠀⢀⡜⣡⣾⣿⢿⣿⣿⣿⣿⣿⢟⣵⣿⣿⣿⣷⣄⠀⣰⣿⣿⣿⣿⣿⣷⣄⠀⢀⣼⣿⣿⣿⣷⡹⣿⣿⣿⣿⣿⣿⢿⣿⣮⡳⡄⠀⠀",
                    "⠀⢠⢟⣿⡿⠋⣠⣾⢿⣿⣿⠟⢃⣾⢟⣿⢿⣿⣿⣿⣾⡿⠟⠻⣿⣻⣿⣏⠻⣿⣾⣿⣿⣿⣿⡛⣿⡌⠻⣿⣿⡿⣿⣦⡙⢿⣿⡝⣆⠀",
                    "⠀⢯⣿⠏⣠⠞⠋⠀⣠⡿⠋⢀⣿⠁⢸⡏⣿⠿⣿⣿⠃⢠⣴⣾⣿⣿⣿⡟⠀⠘⢹⣿⠟⣿⣾⣷⠈⣿⡄⠘⢿⣦⠀⠈⠻⣆⠙⣿⣜⠆",
                    "⢀⣿⠃⡴⠃⢀⡠⠞⠋⠀⠀⠼⠋⠀⠸⡇⠻⠀⠈⠃⠀⣧⢋⣼⣿⣿⣿⣷⣆⠀⠈⠁⠀⠟⠁⡟⠀⠈⠻⠀⠀⠉⠳⢦⡀⠈⢣⠈⢿⡄",
                    "⣸⠇⢠⣷⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⠿⠿⠋⠀⢻⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢾⣆⠈⣷",
                    "⡟⠀⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣶⣤⡀⢸⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡄⢹",
                    "⡇⠀⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠈⣿⣼⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⢸",
                    "⢡⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠶⣶⡟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼",
                    "⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡁⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣼⣀⣠⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                }

                dashboard.section.buttons.val = {}
                alpha.setup(dashboard.opts)
            end,
        },
        {
            'nvim-treesitter/nvim-treesitter',
            branch = 'main',
            lazy = false,
            build = ':TSUpdate',
            config = function()
                local treesitter = require('nvim-treesitter')
                local parsers = {
                    'javascript', 'typescript', 'python', 'c', 'cpp', 'lua',
                    'markdown', 'markdown_inline',
                }

                treesitter.install(parsers)

                vim.api.nvim_create_autocmd('FileType', {
                    pattern = {
                        'javascript', 'javascriptreact',
                        'typescript', 'typescriptreact',
                        'python', 'c', 'cpp', 'lua', 'markdown',
                    },
                    callback = function(args)
                        pcall(vim.treesitter.start, args.buf)
                    end,
                })
            end,
        },
        {
            "hrsh7th/nvim-cmp",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",     -- LSP source
                "hrsh7th/cmp-buffer",       -- Buffer words
                "hrsh7th/cmp-path",         -- File paths
                "L3MON4D3/LuaSnip",         -- Snippet engine (required)
                "saadparwaiz1/cmp_luasnip", -- Snippet source
            },
            config = function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")

                cmp.setup({
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        ["<C-Space>"] = cmp.mapping.complete(),
                        ["<C-e>"]     = cmp.mapping.abort(),
                        ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                        ["<Tab>"]     = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            elseif luasnip.expand_or_jumpable() then
                                luasnip.expand_or_jump()
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                        ["<S-Tab>"]   = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                    }),
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "luasnip" },
                        { name = "buffer" },
                        { name = "path" },
                    }),
                })
            end,
        },
        {
            "iamcco/markdown-preview.nvim",
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            build = "cd app && npm install",
            init = function()
                vim.g.mkdp_filetypes = { "markdown" }
            end,
            ft = { "markdown" },
        },
        {
            "lervag/vimtex",
            tag = "v2.17",
            lazy = false,
            init = function()
                vim.g.vimtex_compiler_method = "latexmk"
                vim.g.vimtex_view_method = "general"
                vim.g.vimtex_view_general_viewer = "xdg-open"
                vim.g.vimtex_view_general_options = "@pdf"
            end,
        },
    },
    -- Colorscheme
    install = { colorscheme = { "rose-pine" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
    rocks = { enabled = false },
})

-- Keymaps

local function current_buffer_dir()
    if vim.bo.filetype == "oil" then
        return require("oil").get_current_dir()
    end

    local buffer_name = vim.api.nvim_buf_get_name(0)
    if buffer_name ~= "" and vim.bo.buftype == "" then
        return vim.fs.dirname(buffer_name)
    end

    return vim.fn.getcwd()
end

--General
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>t", function()
    vim.cmd("terminal")
    vim.cmd("startinsert")
end, { desc = "Open terminal" })
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Fzf
vim.keymap.set("n", "<leader><leader>", function()
    require("fzf-lua").files({ cwd = current_buffer_dir() })
end)

vim.keymap.set("n", "<leader>/", function()
    require("fzf-lua").live_grep({ cwd = current_buffer_dir() })
end)

vim.keymap.set("n", "<leader>b", function()
    require("fzf-lua").buffers()
end)

vim.keymap.set("n", "<leader>r", function()
    require("fzf-lua").lsp_references()
end)

-- Oil
vim.keymap.set("n", "<leader>e", function()
    require("oil").open(current_buffer_dir())
end, { desc = "Open current buffer directory" })

-- Neovide
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_scroll_animation_length = 0

-- Diagnostics
vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
    float = { border = "rounded" },
    signs = true,
    underline = true,
})

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist)
