-- Bootstrap lazy.nvim
local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")
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
vim.o.guifont = "Iosevka Term:h14"
vim.opt.cursorline = false
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
    local powershell = vim.fn.executable("pwsh") == 1 and "pwsh"
        or vim.fn.executable("powershell") == 1 and "powershell"
        or nil

    -- Keep Neovim's COMSPEC default when PowerShell is not installed.
    if powershell then
        vim.opt.shell = powershell
        vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
        vim.opt.shellquote = ""
        vim.opt.shellxquote = ""
        vim.opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
        vim.opt.shellpipe = "2>&1 | Tee-Object %s; exit $LastExitCode"
    end
elseif vim.fn.has("unix") == 1 and vim.fn.executable("zsh") == 1 then
    vim.opt.shell = "zsh"
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
            "miikanissi/modus-themes.nvim",
            lazy = false,
            priority = 1000,
            config = function()
                require("modus-themes").setup({
                    style = "modus_vivendi",
                    styles = {
                        comments = { italic = false },
                        keywords = { italic = false },
                    },
                })
                vim.cmd.colorscheme("modus_vivendi")
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
                "hrsh7th/cmp-cmdline",      -- Command-line completion
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

                cmp.setup.cmdline(":", {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = cmp.config.sources({
                        { name = "path" },
                    }, {
                        {
                            name = "cmdline",
                            option = {
                                ignore_cmds = { "Man", "!" },
                            },
                        },
                    }),
                })
            end,
        },
        {
            "iamcco/markdown-preview.nvim",
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            build = function(plugin)
                local result = vim.system(
                    { "npm", "install" },
                    { cwd = vim.fs.joinpath(plugin.dir, "app") }
                ):wait()
                if result.code ~= 0 then
                    error(result.stderr)
                end
            end,
            init = function()
                vim.g.mkdp_filetypes = { "markdown" }
            end,
            ft = { "markdown" },
        },
        {
            "MeanderingProgrammer/render-markdown.nvim",
            ft = { "markdown" },
            dependencies = { "nvim-treesitter/nvim-treesitter" },
            opts = {},
            keys = {
                {
                    "<leader>mr",
                    "<cmd>RenderMarkdown toggle<cr>",
                    desc = "Toggle Markdown rendering",
                },
            },
        },
        {
            "dhruvasagar/vim-table-mode",
            ft = { "markdown" },
            init = function()
                vim.g.table_mode_map_prefix = "<localleader>t"
                vim.g.table_mode_disable_tableize_mappings = 1
            end,
            keys = {
                {
                    "<leader>mt",
                    "<cmd>TableModeToggle<cr>",
                    desc = "Toggle Markdown table mode",
                },
                {
                    "<leader>ma",
                    "<cmd>TableModeRealign<cr>",
                    desc = "Realign Markdown table",
                },
            },
        },
        {
            "obsidian-nvim/obsidian.nvim",
            version = "*",
            ft = { "markdown" },
            cmd = { "Obsidian" },
            dependencies = { "ibhagwan/fzf-lua" },
            opts = {
                legacy_commands = false,
                workspaces = {
                    {
                        name = "notes",
                        path = vim.env.OBSIDIAN_VAULT or vim.fn.expand("~/notas"),
                    },
                },
                picker = {
                    name = "fzf-lua",
                },
            },
            keys = {
                { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New Obsidian note" },
                { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Find Obsidian note" },
                { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search Obsidian notes" },
            },
        },
        {
            "lervag/vimtex",
            tag = "v2.17",
            lazy = false,
            init = function()
                vim.g.vimtex_compiler_method = "latexmk"
                vim.g.vimtex_view_method = "general"
                if vim.fn.has("win32") == 1 then
                    if vim.fn.executable("SumatraPDF") == 1 then
                        vim.g.vimtex_view_general_viewer = "SumatraPDF"
                        vim.g.vimtex_view_general_options = "-reuse-instance @pdf"
                    else
                        vim.g.vimtex_view_general_viewer = "cmd"
                        vim.g.vimtex_view_general_options = '/c start "" @pdf'
                    end
                elseif vim.fn.executable("xdg-open") == 1 then
                    vim.g.vimtex_view_general_viewer = "xdg-open"
                    vim.g.vimtex_view_general_options = "@pdf"
                end
            end,
        },
    },
    -- Colorscheme
    install = { colorscheme = { "modus_vivendi" } },
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

local function project_root()
    local buffer_dir = current_buffer_dir()
    return vim.fs.root(buffer_dir, { ".git" }) or buffer_dir
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
    require("fzf-lua").files({ cwd = project_root() })
end, { desc = "Find files from project root" })

vim.keymap.set("n", "<leader>/", function()
    require("fzf-lua").live_grep({ cwd = project_root() })
end, { desc = "Grep from project root" })

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
