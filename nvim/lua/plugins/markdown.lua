-- Keep markdown lines within 80 characters
return {
  -- Install prettier through Mason
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "prettier" } },
  },
  -- On save, prettier rewraps paragraphs to 80 columns
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        prettier = {
          prepend_args = function(_, ctx)
            if vim.bo[ctx.buf].filetype:match("^markdown") then
              return { "--prose-wrap", "always", "--print-width", "80" }
            end
            return {}
          end,
        },
      },
    },
  },
  -- Render markdown in the buffer with markview.nvim
  {
    "OXY2DEV/markview.nvim",
    lazy = false, -- markview handles its own lazy loading
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      preview = {
        filetypes = { "markdown" },
        -- In normal mode, show raw markdown on the cursor line
        hybrid_modes = { "n" },
      },
    },
    keys = {
      { "<leader>um", "<cmd>Markview toggle<cr>", desc = "Toggle Markview" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "markdown", "markdown_inline", "html", "yaml" } },
  },
  -- Avoid double rendering if the LazyVim markdown extra is ever enabled
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
}
