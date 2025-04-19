# ChnageLog

## 2025-04-19

### Features
- Open a buffer first which is last focused before Session is saved. [44693d0](https://github.com/Jaehaks/last-session.nvim/commit/44693d0de84d2f19097e9b1a1992cad3d754970e)

### Performance Improvements
- Loading session time is faster than before because unfocused buffer is load by `bufadd` not `edit`. [44693d0](https://github.com/Jaehaks/last-session.nvim/commit/44693d0de84d2f19097e9b1a1992cad3d754970e)


