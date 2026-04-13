#!/usr/bin/env bash
set -euo pipefail

env_file="${OPENCLAW_CONFIG_ENV:-${HOME}/.config/openclaw/openclaw.env}"

if [[ ! -f "$env_file" ]]; then
  echo "missing env file: $env_file" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "$env_file"
set +a

codex_home="${CODEX_HOME:-${HOME}/.codex}"
openclaw_state_dir="${OPENCLAW_STATE_DIR:-${HOME}/.openclaw}"
openclaw_workspace="${OPENCLAW_WORKSPACE:-${openclaw_state_dir}/workspace}"
service_file="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user/openclaw-gateway.service"

required=(
  "${codex_home}/skills/3ms-workspace-ops/SKILL.md"
  "${openclaw_workspace}/bin/qq-3ms-intent"
  "${openclaw_workspace}/profiles/qq/default-tech-assistant.md"
  "${openclaw_state_dir}/openclaw.json"
  "${service_file}"
)

for path in "${required[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "missing: $path" >&2
    exit 1
  fi
done

python3 -m json.tool "${openclaw_state_dir}/openclaw.json" >/dev/null
bash -n "${openclaw_workspace}/bin/qq-3ms-intent"
if command -v openclaw >/dev/null 2>&1; then
  openclaw plugins inspect qqbot-3ms-router >/dev/null
fi

echo "doctor ok"
