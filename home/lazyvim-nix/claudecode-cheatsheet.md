# claudecode.nvim cheatsheet

## Keybinds (Space a …)

| Key | Mode   | Action                            |
|-----|--------|-----------------------------------|
| a c | normal | Toggle terminal                   |
| a f | normal | Focus toggle                      |
| a s | visual | Send selection                    |
| a a | normal | Add file (tree or current buffer) |
| a d | normal | Accept diff                       |
| a x | normal | Reject diff                       |
| a m | normal | Select model                      |

## Commands

`:ClaudeCode [args]`         toggle (args passed to cli)
`:ClaudeCodeAdd % [s] [e]`   add file, optional line range
`:ClaudeCodeStatus`           check websocket connection

## Workflow

1. `SPC a c` open claude
2. Chat, claude edits → diff appears → `SPC a d` / `SPC a x`
3. `SPC a f` bounce between code and claude
4. Select code → `SPC a s` sends it as @mention
5. `SPC a a` adds file — works from file tree or any buffer
