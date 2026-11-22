# Repository Guidelines (`dotfiles`)

## Terminal & Environment Compatibility

This repository targets both modern and legacy/built-in terminal emulators—specifically **macOS Terminal.app**, **GNOME Console (`kgx`)**, and **xfce4-terminal**, as well as Linux virtual consoles (`$TERM == linux`) and SSH sessions.

When adding or modifying shell, prompt, or CLI configurations:

1. **Do not assume Nerd Fonts**:
   - Avoid Private Use Area (PUA) glyphs and `--icons` defaults in `dot_config/starship.toml`, `dot_zsh/config.d/03-alias.zsh` (`eza` / `lsd`), and fallback prompts.
   - Prefer plain-text labels or standard, widely supported Unicode symbols.

2. **Provide Linux TTY (`$TERM == linux`) fallbacks for Emoji and extended Unicode**:
   - Linux virtual consoles use 256/512-glyph PSF bitmap fonts that cannot render Emoji or extended Unicode symbols (e.g., `✦`, `🐍`, `🔒`), causing missing-glyph boxes and prompt width/cursor misalignment.
   - Whenever adding or modifying Emoji or non-ASCII symbol displays, provide an ASCII-safe fallback when `$TERM == linux` (e.g., via `dot_config/starship-tty.toml` selected by `_init_starship`).
   - **Keep `dot_config/starship.toml` and `dot_config/starship-tty.toml` in sync**: Both files must stay identical in layout, colors, modules, and logic, differing only in display symbols/text (`starship-tty.toml` must remain 100% ASCII-safe, including overriding Starship's Emoji defaults such as `[python]` and `[directory]` `read_only`).

3. **Stay 256-color safe**:
   - macOS Terminal.app only supports 256 colors (no 24-bit TrueColor / `COLORTERM=truecolor`).
   - Keep prompt styles, `LESS_TERMCAP`, and `LS_COLORS` legible under 256-color palettes.

4. **Detect GUI/terminal sessions accurately**:
   - Do not gate terminal features solely on `$DISPLAY`. Account for pure Wayland (`$WAYLAND_DISPLAY`), macOS (`$OSTYPE == darwin*`), and SSH (`$SSH_CONNECTION`), while keeping Linux TTY (`$TERM == linux`) handling isolated.

5. **Maintain graceful CLI degradation**:
   - Gate optional modern CLI tools (`starship`, `zoxide`, `fzf`, `eza`, `lsd`, `bat`) behind `_has_tool` with native fallbacks so environments without them—or subshells launched with `vanilla`—remain fully functional.

6. **Known terminal-specific quirks**:
   - **macOS Terminal.app**: Enable *Use Option as Meta key* in profile keyboard settings for `Alt`/`Meta` bindings (e.g., `fzf` `Alt-C`).
   - **xfce4-terminal**: Disable GTK menu shortcut keys in preferences if `Alt+<key>` bindings are intercepted by the menu bar.
   - **GNOME Console / xfce4-terminal**: New-tab directory inheritance (OSC 7) depends on VTE integration (typically `/etc/profile.d/vte.sh`).
