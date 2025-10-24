--[[ keys.lua ]]
local map = vim.api.nvim_set_keymap

-- Toggle nerd-tree
map('n', '<C-b>', [[:NERDTreeToggle<CR>]], {})

-- Search for file
map('n', '<C-p>', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], {  })

-- Comment a line 
map('n', '<C-/>', [[:Commentary<CR>]], {  })
map('v', '<C-/>', [[:Commentary<CR>]], {  })
