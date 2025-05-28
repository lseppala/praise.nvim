if vim.g.loaded_praise then
  return
end
vim.g.loaded_praise = true

-- Create command directly without requiring setup
  vim.api.nvim_create_user_command('Praise', function()
    M.find_pr()
  end, { desc = 'Find and open PR the PR that introduced or changed code on the current line' })
