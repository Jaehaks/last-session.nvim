# ChnageLog

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


