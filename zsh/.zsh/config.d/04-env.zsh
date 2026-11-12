# Added by Antigravity
export PATH="/Users/Foo/.antigravity/antigravity/bin:$PATH"

# opencode
export PATH=/Users/Foo/.opencode/bin:$PATH

# Added by Antigravity IDE
export PATH="/Users/Foo/.antigravity-ide/antigravity-ide/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/Users/Foo/.local/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/Foo/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end


