# Create a new directory and enter it
mkcd () {
  if [[ -z "$1" ]]; then
    printf 'usage: mkcd <directory>\n' >&2
    return 1
  fi

  # Create directories (supports arguments like permissions) and change to the last directory
  mkdir -p -- "$@" && cd -- "${@: -1}"
}
