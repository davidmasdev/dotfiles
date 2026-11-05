return {
  -- Naysayer theme, inspired by Jonathan Blow's Emacs setup
  { "whizikxd/naysayer-colors.nvim", lazy = false, priority = 1000 },

  -- Tell LazyVim to use it
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "naysayer",
    },
  },
}
