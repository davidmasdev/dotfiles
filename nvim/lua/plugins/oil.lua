return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-mini/mini.icons" },
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
    },
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer (Oil)" },
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" },
    },
  },

  -- Remove LazyVim's default explorer keys so they don't clash with Oil
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
}
