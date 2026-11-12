# FreeBSD specific configurations

if [[ $OS == 'FreeBSD' ]]; then
  export PAGER=less
  # On FreeBSD and OpenBSD, custom MANPATH overrides default system paths
  [[ -d "$HOME/.cabal/share/man" ]] && export MANPATH=:$HOME/.cabal/share/man
fi
