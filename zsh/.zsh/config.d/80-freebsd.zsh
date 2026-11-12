# Modification for macOS.

if [[ $OS != *BSD ]]; then
  # FreeBSD 和 OpenBSD 上，MANPATH 会覆盖默认的配置
  [[ -d $HOME/.cabal/share/man ]] && export MANPATH=:$HOME/.cabal/share/man
fi

if [[ $OS = FreeBSD ]]; then
  export PAGER=less
  eval "$(/opt/homebrew/bin/brew shellenv)"
  # eval "$(/opt/homebrew/bin/brew shellenv)"
  alias brew_quick="HOMEBREW_NO_AUTO_UPDATE=1 brew"
  function coreutils_prefix () {
      PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
  }

 if [ "$(arch)" = "arm64" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
 else
    eval "$(/usr/local/bin/brew shellenv)"
 fi

 # bun completions
 # [ -s "/Users/Foo/.bun/_bun" ] && source "/Users/Foo/.bun/_bun"

 # bun
 # export BUN_INSTALL="$HOME/.bun"
 # export PATH="$BUN_INSTALL/bin:$PATH"

 # Claude Code
 [ -s "/Users/Foo/.claude" ] && export PATH="/Users/Foo/.claude/local/node_modules/.bin:$PATH"

fi

