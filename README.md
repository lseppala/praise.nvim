# praise.nvim

> [!TIP]
>  Don't blame. PRaise!

Simple neovim plugin to pull up the Pull Request (PR) on GitHub that introduced or changed the line under your cursor. Extremely useful for getting more context about _why_ the code was written the way it was (including linked issues), and to praise for a job well done.

## Requirements

- The [`gh` cli tool](https://cli.github.com/) must be installed and authenticated with your GitHub account, and SSO must be configured if your organization requires it.
- Neovim 0.5 or later
- Launching browser and copying to clipboard assumes macOS. Open issues if other OS support is wanted.

## Usage

Install with your favorite neovim package manager. Run `:Praise` to open the PR in your browser. It will also add the PR's URL to the clipboard. You can also set up a keymap for convenience.

### Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "lseppala/praise.nvim",
  config = function()
    require("praise").setup({
      -- Optional: set a keymap
      keymap = "<leader>pr",
    })
  end,
}
```

 Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
 Plug 'lseppala/praise.nvim'
```

### Setup

The setup below is optional. The `:Praise` command will work without it, but you can set a keymap to make it easier to use.

Lua configuration:

```lua
require('praise').setup({
  keymap = '<leader>pr'
})
```

Vimscript:

```viml
lua require('praise').setup({ keymap = '<leader>pr' })
```

Alternatively, use a nnoremap:

```viml
nnoremap <leader>pr :Praise<CR>
```

## Development

### Running Tests

This project includes a test suite to ensure the reliability of core functionality. To run the tests:

```bash
cd tests
lua run_tests.lua
```

The test suite currently covers:
- URL parsing for GitHub repositories (HTTPS and SSH formats)
- Edge cases and error handling
- Input validation

Individual test files can also be run directly:

```bash
cd tests
lua parse_github_url_test.lua
```
