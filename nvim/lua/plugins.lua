-- Open `path` in the system default browser.
-- Note: on Nix-on-Linux, Neovim's LD_LIBRARY_PATH points at Nix's libstdc++,
-- which is incompatible with the system glibc and crashes spawned browsers
-- (e.g. `GLIBC_2.38' not found`). We prefix `env -u` to strip those vars from
-- the child's environment. vim.system's `env` table merges with the parent
-- env, so it can't unset inherited keys directly.
local function open_in_browser(path)
  local cmd
  if vim.fn.has('mac') == 1 then
    cmd = { 'open', path }
  elseif vim.fn.has('unix') == 1 then
    cmd = { 'env', '-u', 'LD_LIBRARY_PATH', '-u', 'LD_PRELOAD', 'xdg-open', path }
  elseif vim.fn.has('win32') == 1 then
    cmd = { 'cmd.exe', '/c', 'start', '', path }
  else
    return nil, 'unsupported platform'
  end
  return vim.system(cmd, { detach = true })
end

vim.api.nvim_create_user_command('Preview', function()
  local ft = vim.bo.filetype
  local path = vim.api.nvim_buf_get_name(0)

  if ft == 'markdown' then
    vim.cmd('MarkdownPreview')
  elseif ft == 'html' then
    if path == '' then
      vim.notify(':Preview needs a saved file (current buffer has no name)', vim.log.levels.ERROR)
      return
    end
    local ok, err = pcall(open_in_browser, path)
    if not ok then
      vim.notify(':Preview failed: ' .. tostring(err), vim.log.levels.ERROR)
    end
  else
    vim.notify(':Preview only supports markdown and html (got ' .. ft .. ')', vim.log.levels.WARN)
  end
end, {})

-- Tree-sitter highlighting for html/markdown.
-- nvim-treesitter (post-rewrite) only ships parsers; highlighting is driven
-- by Neovim's built-in vim.treesitter.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'html', 'markdown' },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
