# copilot-cli
## Features

- Toggle the Copilot CLI in a split window (vertical or horizontal).
- Automatically checks if the `copilot` CLI is installed on startup.
- Prompts to install the `copilot` CLI if it's missing.
- Sets the `EDITOR` environment variable to `nvim` for the Copilot CLI session, so you can use Neovim to edit files from within Copilot.

## Requirements

- Neovim >= 0.7.0
- [Node.js and npm](https://nodejs.org/) (for the Gemini CLI)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "andreakinder/copilot-cli.nvim",
  config = function()
    require("copilot").setup({
      split_direction = "horizontal", -- optional: "vertical" (default) or "horizontal"
    })
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "andreakinder/copilot-cli.nvim",
  config = function()
    require("copilot").setup({
      split_direction = "horizontal", -- optional: "vertical" (default) or "horizontal"
    })
  end,
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'andreakinder/copilot-cli.nvim'
```

And then in your `init.lua`:

```lua
require('copilot').setup()
```

## Configuration

The plugin can be configured with the following options:

```lua
require('copilot').setup({
  split_direction = "horizontal", -- "vertical" (default) or "horizontal"
})
```

### Configuration Options

- `split_direction`: Controls how the Gemini CLI window opens
  - `"vertical"` (default): Opens in a vertical split (side by side)
  - `"horizontal"`: Opens in a horizontal split (top and bottom)

### Examples

#### Vertical Split (Default)

```lua
require('copilot').setup() -- or
require('copilot').setup({
  split_direction = "vertical"
})
```

#### Horizontal Split

```lua
require('copilot').setup({
  split_direction = "horizontal"
})
```

## Usage

- Use the keymap `<leader>og` to open and close the Gemini CLI window.
- In visual mode, select one or more lines and use the keymap `<leader>sg` to send the selected text to the Gemini CLI. If the CLI window is not open, a floating message will prompt you to open it first.

When you first run the plugin, it will check if you have the `copilot` CLI installed. If not, it will prompt you to install it.
