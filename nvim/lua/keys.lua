--[[ keys.lua ]]
local map = vim.api.nvim_set_keymap

-- Toggle nerd-tree
map('n', '<C-b>', [[:NERDTreeToggle<CR>]], {})

-- Search for file (VSCode-like Ctrl+P)
map('n', '<C-p>', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], {})

-- Search in current file (VSCode-like Ctrl+F)
map('n', '<C-f>', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]], {})

-- Search across all files (VSCode-like Ctrl+Shift+F, mapped to Ctrl+G due to terminal limitation)
map('n', '<C-g>', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], {})

-- Comment a line
map('n', '<C-/>', [[:Commentary<CR>]], {})
map('v', '<C-/>', [[:Commentary<CR>]], {})
