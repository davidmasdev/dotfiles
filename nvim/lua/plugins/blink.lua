return {
  {
    "saghen/blink.cmp",
    opts = {
      -- No completion suggestions while writing markdown
      enabled = function()
        return vim.bo.filetype ~= "markdown"
      end,
    },
  },
}
