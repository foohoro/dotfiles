# macOS (Darwin) specific configurations

if [[ $OS == 'Darwin' ]]; then
  export PAGER=less

  # Homebrew shell environment initialization
  local brew_bins=(
    "/opt/homebrew/bin/brew"
    "/usr/local/bin/brew"
  )
  for brew_bin in $brew_bins; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done

  alias brew_quick="HOMEBREW_NO_AUTO_UPDATE=1 brew"

  function coreutils_prefix () {
    if (( $+commands[brew] )); then
      PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
    fi
  }

  # Claude Code binary path
  if [[ -d "$HOME/.claude/local/node_modules/.bin" ]]; then
    path=("$HOME/.claude/local/node_modules/.bin" $path)
  fi
fi
