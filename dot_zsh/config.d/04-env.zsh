# Environment paths configuration
# Keep path unique
typeset -U path PATH

# Common candidate binary directories
local candidate_paths=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$HOME/.opencode/bin"
  "$HOME/.antigravity/antigravity/bin"
  "$HOME/.antigravity-ide/antigravity-ide/bin"
  "/opt/homebrew/bin"
  "/usr/local/bin"
)

for p in $candidate_paths; do
  [[ -d "$p" ]] && path=("$p" $path)
done

# pnpm setup
if [[ -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  path=("$PNPM_HOME" $path)
elif [[ -d "$HOME/.local/share/pnpm" ]]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
  path=("$PNPM_HOME" $path)
fi
