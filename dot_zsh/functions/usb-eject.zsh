# Clean .DS_Store and AppleDouble (._*) files on ExFAT/FAT32 USB volumes before ejecting (macOS only).
if [[ $OSTYPE == darwin* ]]; then
  usb-eject () {
    local dry_run=0
    local action="eject"
    local target=""

    while (( $# > 0 )); do
      case "$1" in
        -n|--dry-run)
          dry_run=1
          shift
          ;;
        -u|--unmount)
          action="unmount"
          shift
          ;;
        -h|--help)
          printf 'usage: usb-eject [-n|--dry-run] [-u|--unmount] <volume-name|mount-path>\n'
          return 0
          ;;
        --)
          shift
          break
          ;;
        -*)
          printf 'usb-eject: unknown option: %s\n' "$1" >&2
          return 1
          ;;
        *)
          if [[ -n "$target" ]]; then
            printf 'usage: usb-eject [-n|--dry-run] [-u|--unmount] <volume-name|mount-path>\n' >&2
            return 1
          fi
          target="$1"
          shift
          ;;
      esac
    done

    if [[ -z "$target" && $# -gt 0 ]]; then
      target="$1"
    fi

    # When called without arguments, show usage and list mounted /Volumes entries.
    if [[ -z "$target" ]]; then
      printf 'usage: usb-eject [-n|--dry-run] [-u|--unmount] <volume-name|mount-path>\n' >&2
      local vol
      local found=0
      for vol in /Volumes/*(N); do
        [[ -L "$vol" ]] && continue
        if (( ! found )); then
          printf 'mounted volumes:\n' >&2
          found=1
        fi
        printf '  %s\n' "$vol" >&2
      done
      return 1
    fi

    # Allow passing a bare volume name (e.g., MYUSB -> /Volumes/MYUSB).
    if [[ "$target" != /* && "$target" != .* && -d "/Volumes/$target" ]]; then
      target="/Volumes/$target"
    fi

    if [[ ! -d "$target" ]]; then
      printf 'usb-eject: volume not found: %s\n' "$target" >&2
      return 1
    fi

    local plist
    if ! plist="$(diskutil info -plist "$target" 2>/dev/null)"; then
      printf 'usb-eject: failed to query diskutil info for: %s\n' "$target" >&2
      return 1
    fi

    local mount_point fstype
    mount_point="$(plutil -extract MountPoint raw -o - - <<< "$plist" 2>/dev/null)"
    fstype="$(plutil -extract FilesystemType raw -o - - <<< "$plist" 2>/dev/null)"

    if [[ -z "$mount_point" || "$mount_point" != /Volumes/* ]]; then
      printf 'usb-eject: refusing to operate outside /Volumes: %s\n' "${mount_point:-$target}" >&2
      return 1
    fi

    case "$fstype" in
      exfat|msdos)
        if (( dry_run )); then
          printf '[dry-run] %s (%s): would remove:\n' "$mount_point" "$fstype"
          find "$mount_point" \( -name '.DS_Store' -o -name '._*' \) -print
          printf '[dry-run] would run: diskutil %s %s\n' "$action" "$mount_point"
          return 0
        fi

        printf 'usb-eject: cleaning %s (%s)...\n' "$mount_point" "$fstype"
        if (( $+commands[dot_clean] )); then
          dot_clean -m -- "$mount_point" 2>/dev/null
        fi
        find "$mount_point" \( -name '.DS_Store' -o -name '._*' \) -delete
        ;;
      *)
        printf 'usb-eject: %s is %s (not exfat/msdos); skipping cleanup.\n' "$mount_point" "${fstype:-unknown}"
        if (( dry_run )); then
          printf '[dry-run] would run: diskutil %s %s\n' "$action" "$mount_point"
          return 0
        fi
        ;;
    esac

    diskutil "$action" "$mount_point"
  }
fi
