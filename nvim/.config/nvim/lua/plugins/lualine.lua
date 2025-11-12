return{
    'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup({
      options = {
        theme = 'github_dark_default'
      }
    })
   end
}
