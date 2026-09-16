#!/bin/bash
set -euo pipefail

picker="$HOME/.config/zellij/bin/zellij-pane-picker"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

cat >"$tmp_dir/panes.json" <<'JSON'
[
  {"id":1,"is_plugin":false,"is_focused":false,"is_fullscreen":false,"is_floating":false,"is_suppressed":false,"title":"api","exited":false,"is_selectable":true,"tab_id":4,"pane_command":"nvim","pane_cwd":"/home/hugo/checkout/api"},
  {"id":2,"is_plugin":false,"is_focused":false,"is_fullscreen":false,"is_floating":false,"is_suppressed":false,"title":"worker","exited":false,"is_selectable":true,"tab_id":4,"pane_command":"bash","pane_cwd":"/home/hugo/checkout/worker"},
  {"id":9,"is_plugin":false,"is_focused":true,"is_fullscreen":false,"is_floating":true,"is_suppressed":false,"title":"pane-picker","exited":false,"is_selectable":true,"tab_id":4,"pane_command":"zellij-pane-picker","pane_cwd":"/home/hugo"},
  {"id":3,"is_plugin":true,"is_focused":false,"is_fullscreen":false,"is_floating":false,"is_suppressed":false,"title":"status-bar","exited":false,"is_selectable":true,"tab_id":4,"plugin_url":"zellij:status-bar"},
  {"id":5,"is_plugin":false,"is_focused":false,"is_fullscreen":false,"is_floating":false,"is_suppressed":false,"title":"old","exited":true,"is_selectable":true,"tab_id":4,"pane_command":"bash","pane_cwd":"/tmp/old"},
  {"id":7,"is_plugin":false,"is_focused":false,"is_fullscreen":false,"is_floating":false,"is_suppressed":false,"title":"other-tab","exited":false,"is_selectable":true,"tab_id":8,"pane_command":"nvim","pane_cwd":"/tmp/other"}
]
JSON

cat >"$tmp_dir/zellij" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$ZELLIJ_TEST_LOG"
SH

cat >"$tmp_dir/fzf" <<'SH'
#!/bin/bash
input=$(cat)
printf '%s' "$input" >"$FZF_TEST_INPUT"
if [[ ${FZF_TEST_CANCEL:-0} == 1 ]]; then
  exit 130
fi
printf '%s\n' "$input" | sed -n "${FZF_TEST_LINE:-1}p"
SH

chmod +x "$tmp_dir/zellij" "$tmp_dir/fzf"

assert_contains() {
  local file=$1
  local expected=$2
  grep -Fq "$expected" "$file" || {
    printf 'Expected %s to contain: %s\n' "$file" "$expected" >&2
    exit 1
  }
}

assert_not_contains() {
  local file=$1
  local unexpected=$2
  if grep -Fq "$unexpected" "$file"; then
    printf 'Expected %s not to contain: %s\n' "$file" "$unexpected" >&2
    exit 1
  fi
}

export PATH="$tmp_dir:$PATH"
export ZELLIJ=1
export ZELLIJ_PANE_ID=9
export ZELLIJ_PANES_JSON="$tmp_dir/panes.json"
export ZELLIJ_TEST_LOG="$tmp_dir/zellij.log"
export FZF_TEST_INPUT="$tmp_dir/fzf.input"

"$picker"

assert_contains "$FZF_TEST_INPUT" $'1\tapi\tnvim\t/home/hugo/checkout/api'
assert_contains "$FZF_TEST_INPUT" $'2\tworker\tbash\t/home/hugo/checkout/worker'
assert_not_contains "$FZF_TEST_INPUT" "pane-picker"
assert_not_contains "$FZF_TEST_INPUT" "status-bar"
assert_not_contains "$FZF_TEST_INPUT" "old"
assert_not_contains "$FZF_TEST_INPUT" "other-tab"
assert_contains "$ZELLIJ_TEST_LOG" "action focus-pane-id terminal_1"
assert_not_contains "$ZELLIJ_TEST_LOG" "toggle-fullscreen"

jq 'map(if .id == 1 then .is_fullscreen = true else . end)' "$tmp_dir/panes.json" >"$tmp_dir/fullscreen-panes.json"
: >"$ZELLIJ_TEST_LOG"
ZELLIJ_PANES_JSON="$tmp_dir/fullscreen-panes.json" FZF_TEST_LINE=2 "$picker"
assert_contains "$ZELLIJ_TEST_LOG" "action focus-pane-id terminal_2"
assert_contains "$ZELLIJ_TEST_LOG" "action toggle-fullscreen --pane-id terminal_2"

: >"$ZELLIJ_TEST_LOG"
FZF_TEST_CANCEL=1 "$picker"
[[ ! -s "$ZELLIJ_TEST_LOG" ]] || {
  printf 'Expected cancellation not to focus a pane\n' >&2
  exit 1
}

if /usr/bin/env -u ZELLIJ "$picker" >"$tmp_dir/outside.out" 2>"$tmp_dir/outside.err"; then
  printf 'Expected picker to fail outside Zellij\n' >&2
  exit 1
fi
assert_contains "$tmp_dir/outside.err" "inside Zellij"

printf 'zellij-pane-picker tests passed\n'
