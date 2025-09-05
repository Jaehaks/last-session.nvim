# ChnageLog

## 2025-07-07

### Features
- Remember the cursor line position of all buffers when session is loaded [42886e4](https://github.com/Jaehaks/last-session.nvim/commit/42886e49a54b1df74df76966a67270394a2d8409).
	- `last-session.nvim` remembers cursor location of last focused window only before.
	- Now, It takes cursor to last located position for all buffers.
	- Due to limit of `getbufinfo()`, row number of cursor location which are not shown at last window is restored only.

### Bug Fixed
- Bug fix for [42886e4](https://github.com/Jaehaks/last-session.nvim/commit/42886e49a54b1df74df76966a67270394a2d8409) at [056f29e](https://github.com/Jaehaks/last-session.nvim/commit/056f29e850fa8e91369672a7e55651af5aee74f9)
	- Save cursor position even though some buffers are listed but not loaded from session file.

## 2025-07-07

### Features
- Remove current session when `load_session()` is executed [167e8c0](https://github.com/Jaehaks/last-session.nvim/commit/167e8c01b0c033ce2427a05197b05d7640d63e05)
	- After load session, close buffers in before session

### Bug Fixed
- Bug fix about ghost window [bc55589](https://github.com/Jaehaks/last-session.nvim/commit/bc555899dc877756e44af0b3f69017ddd9c66f52)
	- Sometimes, although neovim had only one window and it focused, there are two `windows` data in session_data file
	- It makes error when I load session because there are no valid buffer in one `windows` data
	- Remove invalid window when `save_session()` is executed

## 2025-06-29

### Features
- Add Vim Command for save_session() and load_session() [0ee3939](https://github.com/Jaehaks/last-session.nvim/commit/0ee393979b39733d3717cd821308edd050c815fe)
	- `:LastSessionSave` : `require('last-session').save_session()`
	- `:lastsessionload` : `require('last-session').load_session()`

### Bug Fixed
- Fix error about deleting buffer when no-named files are listed. [3390591](https://github.com/Jaehaks/last-session.nvim/commit/339059128940fba84d3cb2352f75f7d976f58312)
- Don't save session file if there are no candidate files [a90dbc7](https://github.com/Jaehaks/last-session.nvim/commit/a90dbc7d2f6b00d84214a2abc598a95d378c3e4a)
	- When I quit neovim just after dashboard is shown, it has no effect to the session file
- Don't proceed load_session() anymore when there are no saved session [2d14691](https://github.com/Jaehaks/last-session.nvim/commit/2d146911f96fd3a3559f072ca8af0d1bc1817101)

## 2025-04-20 (2)

### Features
- Sessions are saved based on window not buffer. [e08d1f8](https://github.com/Jaehaks/last-session.nvim/commit/e08d1f86571b753161d1fae80d6c616f2707faf5)
	- `last-session.nvim` can save window layout now
	-  first window cannot restore topline but cursor can be that.

### Bug Fixed
- set focused_winid as winid from winnum [e08d1f8](https://github.com/Jaehaks/last-session.nvim/commit/e08d1f86571b753161d1fae80d6c616f2707faf5)

## 2025-04-20

### Features
- Session file's contents can be shown in neovim using `:LastSessionView` command. [d35e889](https://github.com/Jaehaks/last-session.nvim/commit/d35e889e8a5db1460ea60a0ade4a116227cfd7ba)
- Remove empty buffer list in session file. [702af08](https://github.com/Jaehaks/last-session.nvim/commit/702af0850529c51611256d848b6edbf1cbd96742)
- Keep cursor and view state of last focused buffer [7aead3e](https://github.com/Jaehaks/last-session.nvim/commit/7aead3e6799f42bb30a161bef0b67f9308dde395)

### Bug Fixed
- When all buffers are unfocused, first buffer is focused [396f25e](https://github.com/Jaehaks/last-session.nvim/commit/396f25eac16442df14e674704ad56a7a56371b0f)

### Added
- Add "API" section to README. [fc73afe](https://github.com/Jaehaks/last-session.nvim/commit/fc73afefe9b306d6c5a39921a7489a8ca2be7693)


## 2025-04-19

### Features
- Open a buffer first which is last focused before Session is saved. [44693d0](https://github.com/Jaehaks/last-session.nvim/commit/44693d0de84d2f19097e9b1a1992cad3d754970e)

### Performance Improvements
- Loading session time is faster than before because unfocused buffer is load by `bufadd` not `edit`. [44693d0](https://github.com/Jaehaks/last-session.nvim/commit/44693d0de84d2f19097e9b1a1992cad3d754970e)
- Refactoring `load_session()` to readability. [2b4f581](https://github.com/Jaehaks/last-session.nvim/commit/2b4f58168e83c346d3d21aadae0004b6a84c233b)


