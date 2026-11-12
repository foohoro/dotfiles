# 命令别名 {{{2
# Modern CLI alternatives with graceful degradation
# ls family: eza -> lsd -> native ls
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto'
  alias ll='eza -lh --icons=auto'
  alias la='eza -lha --icons=auto'
  alias tree='eza --tree --icons=auto'
elif (( $+commands[lsd] )); then
  alias ls='lsd'
  alias ll='lsd -l'
  alias la='lsd -la'
  alias tree='lsd --tree'
elif [[ $OS == 'Linux' ]]; then
  alias ls='ls --color=auto'
  alias ll='ls -lh'
  alias la='ls -A'
elif [[ $OS == 'FreeBSD' || $OS == 'Darwin' ]]; then
  alias ls='ls -G'
  alias ll='ls -lh'
  alias la='ls -A'
elif (( $+commands[colorls] )); then
  alias ls='colorls -G'
  alias ll='ls -lh'
  alias la='ls -A'
else
  alias ls='ls -F'
  alias ll='ls -lh'
  alias la='ls -A'
fi

# cat / pager: bat -> native cat
if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
fi

if [[ $OS == 'Linux' || $OS == 'FreeBSD' || $OS == 'Darwin' ]]; then
  alias grep='grep --color=auto'
fi

# grc aliases 
if (( $+aliases[colourify] )); then
  # default is better
  unalias gcc g++ 2>/dev/null || true
  # bug: https://github.com/garabik/grc/issues/72
  unalias mtr     2>/dev/null || true
  # buffering issues: https://github.com/garabik/grc/issues/25
  unalias ping    2>/dev/null || true
fi

# for systemd 230+
# see https://github.com/tmux/tmux/issues/428
if [[ $_has_re -eq 1 ]] && \
  (( $+commands[tmux] )) && (( $+commands[systemctl] )); then
  [[ $(systemctl --version) =~ 'systemd ([0-9]+)' ]] || true
  if [[ $match -ge 230 ]]; then
    tmux () {
      if command tmux has; then
        command tmux $@
      else
        systemd-run --user --scope tmux $@
      fi
    }
  fi
  unset match
fi

alias nicest="nice -n19 ionice -c3"

# 查看进程数最多的程序
alias topnum="ps -e|sort -k4|awk '{print \$4}'|uniq -c|sort -n|tail"

alias nonet="HTTP_PROXY='http://localhost:1' HTTPS_PROXY='http://localhost:1' FTP_PROXY='http://localhost:1' http_proxy='http://localhost:1' https_proxy='http://localhost:1' ftp_proxy='http://localhost:1'"

# Quick toggle proxy functions
proxy_on () {
  local port="${1:-7890}"
  export http_proxy="http://127.0.0.1:$port"
  export https_proxy="http://127.0.0.1:$port"
  export all_proxy="socks5://127.0.0.1:$port"
  export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
  printf 'Proxy set to 127.0.0.1:%s\n' "$port"
}

proxy_off () {
  unset http_proxy https_proxy all_proxy no_proxy
  printf 'Proxy environment variables unset\n'
}
alias fromgbk="iconv -t latin1 | iconv -f gb18030"
alias swaptop='watch -n 1 "swapview | tail -\$((\$LINES - 2)) | cut -b -\$COLUMNS"'
alias pkg-check='comm -23 <(pacman -Qetq|sort) <(awk ''{print $1}'' ~/etc/pkg-why|sort) | shuf | tail -$(( LINES - 4 ))'

# for systemd {{{3
alias sysuser="systemctl --user"
function juser () {
  # sadly, this won't have nice completion
  typeset -a args
  integer nextIsService=0 isfirst
  for i; do
    if [[ $i == -u ]]; then
      nextIsService=1
    else
      if [[ $nextIsService -eq 1 ]]; then
        nextIsService=0
        isfirst=1
        for g in $(journalctl --user -F _SYSTEMD_CGROUP|command grep -P "^/user\\.slice/user-$UID\\.slice/user@$UID\\.service/$i\."); do
          if [[ isfirst -eq 1 ]]; then
            args=($args _SYSTEMD_CGROUP=$g)
          else
            args=($args + _SYSTEMD_CGROUP=$g)
          fi
          isfirst=0
        done
        if [[ isfirst -eq 1 ]]; then
          args=($args USER_UNIT=$i.service)
        else
          args=($args + USER_UNIT=$i.service)
        fi
      else
        args=($args $i)
      fi
    fi
  done
  journalctl -n $((${LINES:=40} - 4)) --user ${^args}
}
alias privoxy_log="juser -u privoxy -a -f | ssed -R 's/(?<=\]:) [\d-]+ [\d:.]+ [\da-f]+//'"

# 后缀别名 {{{2
alias -s xsl="vim"
alias -s {html,htm}="firefox"
alias -s {pdf,ps,djvu}="evince"
alias -s ttf="gnome-font-viewer"
alias -s {png,jpg,gif}="feh"
alias -s jar="java -jar"

# 路径别名 {{{2
# hash -d directory="/path/to/your/long_long_directory :-)"

# 全局别名 {{{2
# 当前目录下最后修改的文件
# 来自 http://roylez.heroku.com/2010/03/06/zsh-recent-file-alias.html
alias -g NN="*(oc[1])"
alias -g NNF="*(oc[1].)"
alias -g NND="*(oc[1]/)"
alias -g NUL="/dev/null"
alias -g XS='"$(xsel)"'
alias -g ANYF='**/*[^~](.)'
