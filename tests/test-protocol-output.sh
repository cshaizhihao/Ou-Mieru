#!/usr/bin/env bash

set -Eeuo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# The sourced functions consume the test values below at runtime.
# shellcheck disable=SC1091,SC2034
. "$repo_dir/nobrand"

# shellcheck disable=SC2034
PROXY_USER='test-user'
# shellcheck disable=SC2034
PROXY_PASSWORD='test-password'
# shellcheck disable=SC2034
ENTRY_HOST='211.136.162.188'
# shellcheck disable=SC2034
ENTRY_PORT='7078'
# shellcheck disable=SC2034
NODE_NAME='ou-mieru-test'

expected='mieru://test-user:test-password@211.136.162.188:7078/?transport=TCP&mtu=1400&multiplexing=MULTIPLEXING_OFF#ou-mieru-test'
actual="$(mieru_uri)"

[[ "$actual" == "$expected" ]] || {
  printf '协议链接不符合预期。\n期望：%s\n实际：%s\n' "$expected" "$actual" >&2
  exit 1
}

protocol_output="$(print_protocol)"
grep -Fq 'Mieru 兼容协议链接：' <<<"$protocol_output"
grep -Fq 'type: mieru' <<<"$protocol_output"
grep -Fq 'server: 211.136.162.188' <<<"$protocol_output"
grep -Fq 'port: 7078' <<<"$protocol_output"
