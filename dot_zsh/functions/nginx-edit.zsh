# Edit a remote Nginx configuration file by domain (or explicit path),
# validate with `nginx -t`, and reload only when changes were made.
nginx-edit () {
  local host=""
  local target_arg=""
  local action="reload"

  while (( $# > 0 )); do
    case "$1" in
      -r|--restart)
        action="restart"
        shift
        ;;
      -h|--help)
        printf 'usage: nginx-edit [-r|--restart] <ssh-host> <domain|path>\n'
        return 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        printf 'nginx-edit: unknown option: %s\n' "$1" >&2
        return 1
        ;;
      *)
        if [[ -z "$host" ]]; then
          host="$1"
        elif [[ -z "$target_arg" ]]; then
          target_arg="$1"
        else
          printf 'usage: nginx-edit [-r|--restart] <ssh-host> <domain|path>\n' >&2
          return 1
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$host" || -z "$target_arg" ]]; then
    printf 'usage: nginx-edit [-r|--restart] <ssh-host> <domain|path>\n' >&2
    return 1
  fi

  local remote_script='
    set -euo pipefail
    arg="$1"
    action="$2"

    # Cache sudo credentials upfront so subsequent steps do not re-prompt.
    sudo -v

    if [[ "$arg" == /* ]]; then
      target="$arg"
    else
      mapfile -t files < <(
        sudo nginx -T 2>/dev/null | awk -v dom="$arg" '\''
          /^# configuration file / {
            f = $0
            sub(/^# configuration file /, "", f)
            sub(/:$/, "", f)
            next
          }
          $1 == "server_name" {
            for (i = 2; i <= NF; i++) {
              v = $i
              sub(/;$/, "", v)
              if (v == dom) {
                print f
                break
              }
            }
          }
        '\'' | sort -u
      )

      if (( ${#files[@]} == 0 )); then
        printf "No active Nginx config found for domain: %s\n" "$arg" >&2
        exit 1
      elif (( ${#files[@]} == 1 )); then
        target="${files[0]}"
      else
        printf "Multiple matching configs found:\n"
        select target in "${files[@]}"; do
          [[ -n "$target" ]] && break
        done
      fi
    fi

    # Resolve symlinks (e.g. sites-enabled -> sites-available) for sudoedit.
    target="$(readlink -f "$target")"
    if [[ ! -f "$target" ]]; then
      printf "Config file not found: %s\n" "$target" >&2
      exit 1
    fi

    printf "Editing: %s\n" "$target"

    file_hash () {
      if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk "{print \$1}"
      else
        cksum "$1" | awk "{print \$1\":\"\$2}"
      fi
    }

    h1="$(file_hash "$target")"
    sudo -e "$target"
    h2="$(file_hash "$target")"

    if [[ "$h1" == "$h2" ]]; then
      printf "No changes detected; skipping test and %s.\n" "$action"
      exit 0
    fi

    sudo nginx -t
    if [[ "$action" == "restart" ]]; then
      if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl restart nginx
      else
        sudo service nginx restart
      fi
    else
      if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl reload nginx
      else
        sudo nginx -s reload
      fi
    fi
  '

  ssh -t "$host" "bash -c ${(q)remote_script} _ ${(q)target_arg} ${(q)action}"
}
