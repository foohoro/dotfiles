bindkey -e

# ^Xe 用$EDITOR编辑命令
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

zle -C complete-file menu-expand-or-complete _generic
zstyle ':completion:complete-file:*' completer _files

# https://archive.zhimingwang.org/blog/2015-09-21-zsh-51-and-bracketed-paste.html
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic

# zsh 5.1+ uses bracketed-paste-url-magic
if [[ $ZSH_VERSION =~ '^[0-4]\.' || $ZSH_VERSION =~ '^5\.0\.[0-9]' ]]; then
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic
  toggle-uqm () {
    if zle -l self-insert; then
      zle -A .self-insert self-insert && zle -M "switched to self-insert"
    else
      zle -N self-insert url-quote-magic && zle -M "switched to url-quote-magic"
    fi
  }
  zle -N toggle-uqm
  bindkey '^X$' toggle-uqm
fi

# better than copy-prev-word
bindkey "^[^_" copy-prev-shell-word

insert-last-word-r () {
  zle insert-last-word -- 1
}
zle -N insert-last-word-r
bindkey "\e_" insert-last-word-r

autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey '\e=' copy-earlier-word

autoload -Uz prefix-proxy
zle -N prefix-proxy
bindkey "^Xp" prefix-proxy

zmodload zsh/complist
bindkey -M menuselect '^O' accept-and-infer-next-history

bindkey "^X^I" complete-file
bindkey "^X^f" complete-file
bindkey "^U" backward-kill-line
bindkey "^]" vi-find-next-char
bindkey "\e]" vi-find-prev-char
bindkey "\eq" push-line-or-edit
bindkey -s "\e[Z" "^P"
bindkey '^Xa' _expand_alias
bindkey '^[/' _history-complete-older
bindkey '\e ' set-mark-command
bindkey "\e[3~" delete-char

# 用单引号引起最后一个单词
# FIXME 如何引起光标处的单词？
bindkey -s "^['" "^[] ^f^@^e^[\""

bindkey '^[p' up-line-or-search
bindkey '^[n' down-line-or-search
bindkey "e[1~" beginning-of-line
bindkey "e[4~" end-of-line
bindkey "e[5~" beginning-of-history
bindkey "e[6~" end-of-history
bindkey "e[3~" delete-char
bindkey "e[2~" quoted-insert
bindkey "e[5C" forward-word
bindkey "eOc" emacs-forward-word
bindkey "e[5D" backward-word
bindkey "eOd" emacs-backward-word
bindkey "ee[C" forward-word
bindkey "ee[D" backward-word
bindkey "^H" backward-delete-word

# jump to a position in a command line {{{2
# https://github.com/scfrazer/zsh-jump-target
autoload -Uz jump-target
zle -N jump-target
bindkey "^J" jump-target

# restoring an aborted command-line {{{2
# unsupported with 4.3.17
if zle -la split-undo; then
  zle-line-init () {
    if [[ -n $ZLE_LINE_ABORTED ]]; then
      _last_aborted_line=$ZLE_LINE_ABORTED
    fi
    if [[ -n $_last_aborted_line ]]; then
      local savebuf="$BUFFER" savecur="$CURSOR"
      BUFFER="$_last_aborted_line"
      CURSOR="$#BUFFER"
      zle split-undo
      BUFFER="$savebuf" CURSOR="$savecur"
    fi
  }
  zle -N zle-line-init
  zle-line-finish() {
    unset _last_aborted_line
  }
  zle -N zle-line-finish
fi
# move by shell word {{{2
zsh-word-movement () {
  # see select-word-style for more
  local -a word_functions
  local f

  word_functions=(backward-kill-word backward-word
    capitalize-word down-case-word
    forward-word kill-word
    transpose-words up-case-word)

  if ! zle -l $word_functions[1]; then
    for f in $word_functions; do
      autoload -Uz $f-match
      zle -N zsh-$f $f-match
    done
  fi
  # set the style to shell
  zstyle ':zle:zsh-*' word-style shell
}
zsh-word-movement
unfunction zsh-word-movement
bindkey "\eB" zsh-backward-word
bindkey "\eF" zsh-forward-word
bindkey "\eW" zsh-backward-kill-word
# Esc-Esc 在当前/上一条命令前插入 sudo {{{2
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * && $UID -ne 0 ]] && {
      typeset -a bufs
      bufs=(${(z)BUFFER})
      while (( $+aliases[$bufs[1]] )); do
        local expanded=(${(z)aliases[$bufs[1]]})
        bufs[1,1]=($expanded)
        if [[ $bufs[1] == $expanded[1] ]]; then
          break
        fi
      done
      bufs=(sudo $bufs)
      BUFFER=$bufs
    }
    zle end-of-line
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line
# 插入当前的所有补全 http://www.zsh.org/mla/users/2000/msg00601.html {{{2
_insert_all_matches () {
    setopt localoptions nullglob rcexpandparam extendedglob noshglob
    unsetopt markdirs globsubst shwordsplit nounset ksharrays
    compstate[insert]=all
    compstate[old_list]=keep
    _complete
}
zle -C insert-all-matches complete-word _insert_all_matches
bindkey '^Xi' insert-all-matches

# Search history with text on the line, powered by Zle's history-search.
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward