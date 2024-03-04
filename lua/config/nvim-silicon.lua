require('silicon').setup {
  font = 'FantasqueSansM Nerd Font=26',
  theme = "Nord",
  background = "#8DD8D4",
  window_title = function ()
    return vim.fn.fnamemodify(
      vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":t"
    )
  end
}
