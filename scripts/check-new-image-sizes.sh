#!/bin/sh
set -eu

limit_bytes=$((3 * 1024 * 1024))
failed=0
tmp_file=$(mktemp "${TMPDIR:-/tmp}/check-new-image-sizes.XXXXXX")
trap 'rm -f "$tmp_file"' EXIT HUP INT TERM

git diff --cached --name-only --diff-filter=AM -- assets/images > "$tmp_file"

while IFS= read -r path; do
  case "$path" in
    *.jpg|*.jpeg|*.png|*.webp)
      if [ -f "$path" ]; then
        size=$(wc -c < "$path" | tr -d ' ')
        if [ "$size" -gt "$limit_bytes" ]; then
          printf '%s is %s bytes; optimize before committing. Limit is %s bytes.\n' "$path" "$size" "$limit_bytes"
          failed=1
        fi
      fi
      ;;
  esac
done < "$tmp_file"

exit "$failed"
