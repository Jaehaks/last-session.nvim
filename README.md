# last-sessions.nvim

Save and Load sessions without `:mksessions`

## Why?

There are many plugins to save and restore current session to file.
I used some plugins which wrapped native `:mksession` of neovim. But the `:mksession` and restore
command doesn't work what I expected. They omitted some files from opened buffer.
And some plugins have too heavy features to use this plugin for just saving last session.
So I made this plugin without using `:mksession` and restore opened buffer files correctly when VimLeave.

It is still developing, so I'll fix it continuously until I satisfied.


## Installation

```lua
	-- lazy.nvim
	return {
		'Jaehaks/last-session.nvim',
			branch = 'main',
			opts = {}
	}
```

## configuration

```lua
-- This is default configuration
opts = {
	auto_save    = false,     -- save last session automatically when VimLeave
	path         = vim.fn.stdpath('data') .. '/last-session/last-session.json',
	ignored_list = {
		ignored_type = {},    -- List of file extensions or filetypes to ignore
		ignored_dir  = {},    -- List of directory path patterns to ignore
	}
}
```

### ignored_list

It is table which includes filetype, extension or directory string pattern to ignore for session
```lua
	-- example
	ignored_list = {
		ignored_type = {
			'help',
		},
		ignored_dir = {
			'doc\\',
		}
	}
```

## API / Command

### API

`session = require('last-session').save_session()`

|           API            | behavior                           |
| :----------------------: | ---------------------------------- |
| `session.save_session()` | Save current tab session to file   |
| `session.load_session()` | Load current tab session from file |

### Command

|      Command       | behavior                                   |
| :----------------: | ------------------------------------------ |
| `:LastSessionView` | Show contents of saved session file (json) |
|                    | Read only, 'q' to quit                     |






