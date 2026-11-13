-- On Omarchy, lua/plugins/theme.lua (a symlink to the current Omarchy theme)
-- sets the colorscheme and omarchy-theme-hotreload.lua follows theme changes.
-- Naysayer stays installed: switch to it any time with :colorscheme naysayer.
-- On machines without Omarchy, naysayer is the default.
local has_omarchy_theme = vim.uv.fs_stat(vim.fn.stdpath("config") .. "/lua/plugins/theme.lua") ~= nil

return {
  -- Naysayer theme, inspired by Jonathan Blow's Emacs setup
  { "whizikxd/naysayer-colors.nvim", lazy = false, priority = 1000 },

  -- Tell LazyVim to use it when there is no Omarchy theme
  {
    "LazyVim/LazyVim",
    opts = has_omarchy_theme and {} or {
      colorscheme = "naysayer",
    },
  },
}
