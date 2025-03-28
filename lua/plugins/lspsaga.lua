local function map_keys(key, command, description)
  vim.keymap.set('n', '<prefix>' .. key, '<cmd> Lspsaga ' .. command .. ' <cr>', { desc = description })
end

return {
  {
    'nvimdev/lspsaga.nvim',
    -- ft = 'java',
    config = function()
      map_keys('pd', 'peek_type_definition', 'Lspsaga Peek Definition')

      require('lspsaga').setup({})
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
    },
    keys = {
      {
        'n',
        '<prefix>pd',
        '<cmd> Lspsaga peek_type_definition <cr>',
        desc = 'Lspsaga Peek Definition'
      },
      {
        'n',
        '<prefix>dn',
        '<cmd> Lspsaga diagnostic_jump_next <cr>',
        desc = 'Lspsaga Diagnostic Jump Next'
      },
      {
        'n',
        '<prefix>dn',
        '<cmd> Lspsaga diagnostic_jump_prev <cr>',
        desc = 'Lspsaga Diagnostic Jump Previous'
      },
      {
        'n',
        '<prefix>hd',
        '<cmd> Lspsaga hover_doc <cr>',
        desc = 'Lspsaga Hover Doc'
      },
      {
        'n',
        '<prefix>ic',
        '<cmd> Lspsaga incoming_calls <cr>',
        desc = 'Lspsaga Incoming Call Hierarchy'
      },
      {
        'n',
        '<prefix>oc',
        '<cmd> Lspsaga outgoing_calls <cr>',
        desc = 'Lspsaga Outgoing Call Hierarchy'
      },
    }
  },
}
