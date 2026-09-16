#!/bin/bash
set -euo pipefail

launcher="$HOME/.config/zellij/bin/zellij-fvim-pane"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

cat >"$tmp_dir/zellij" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$ZELLIJ_TEST_LOG"
SH

cat >"$tmp_dir/zsh" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$ZSH_TEST_LOG"
SH
chmod +x "$tmp_dir/zellij" "$tmp_dir/zsh"

assert_contains() {
  local file=$1
  local expected=$2
  grep -Fq -- "$expected" "$file" || {
    printf 'Expected %s to contain: %s\n' "$file" "$expected" >&2
    exit 1
  }
}

export PATH="$tmp_dir:$PATH"
export ZELLIJ=1
export ZELLIJ_PANE_ID=42
export ZELLIJ_TEST_LOG="$tmp_dir/zellij.log"
export ZSH_TEST_LOG="$tmp_dir/zsh.log"

"$launcher"

assert_contains "$ZELLIJ_TEST_LOG" "action toggle-fullscreen --pane-id terminal_42"
assert_contains "$ZSH_TEST_LOG" "-ic fvim"

if /usr/bin/env -u ZELLIJ "$launcher" >"$tmp_dir/outside.out" 2>"$tmp_dir/outside.err"; then
  printf 'Expected launcher to fail outside Zellij\n' >&2
  exit 1
fi
assert_contains "$tmp_dir/outside.err" "inside Zellij"

printf 'zellij-fvim-pane tests passed\n'
