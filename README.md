# praise.nvim

> Don't blame. Praise!

Simple neovim plugin to pull up the GitHub pull request (PR) that introduced or changed the line under your cursor. Extremely useful for getting more context about _why_ the code was written the way it was (including linked issues) and to praise for a job well done.

## Requirements

- The [`gh` cli tool](https://cli.github.com/) must be installed and authenticated with your GitHub account, and SSO must be configured if your organization requires it.
- Neovim 0.5 or later

## Usage

Install with your favorite neovim package manager. Run `:Praise` to open the PR in your browser. It will also add the PR's URL to kkkk. You can also set up a keymap for convenience.

### Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

````lua
{
  "lseppala/praise.nvim",
  config = function()
    require("praise.nvim").setup({
      -- Optional: set a keymap
      keymap = "<leader>pr",
    })
  end,
}


 Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
 Plug 'lseppala/praise.nvim'
```

### Setup

The setup below is optional. The `:Praise` command will work without it, but you can set a keymap to make it easier to use.

Lua configuration:

```lua
  require('praise').setup({
    keymap = '<leader>pr'
  })
````

Vimscript:

```vim
  lua require('praise').setup({
    keymap = '<leader>pr'
  })
```

Alternatively use a nnoremap:

```vim
nnoremap <leader>pr :Praise<CR>
```
