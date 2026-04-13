#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_file="${OPENCLAW_CONFIG_ENV:-${HOME}/.config/openclaw/openclaw.env}"
restart_service="0"
skip_systemd="${OPENCLAW_SKIP_SYSTEMD:-0}"

copy_dir_contents() {
  local src_dir="$1"
  local dest_dir="$2"
  local item
  local dest_path

  mkdir -p "$dest_dir"
  shopt -s dotglob nullglob
  for item in "$src_dir"/*; do
    dest_path="${dest_dir}/$(basename "$item")"
    if [[ -e "$dest_path" ]] && [[ "$(readlink -f "$item")" == "$(readlink -f "$dest_path")" ]]; then
      continue
    fi
    cp -a "$item" "$dest_dir/"
  done
  shopt -u dotglob nullglob
}

for arg in "$@"; do
  case "$arg" in
    --restart)
      restart_service="1"
      ;;
    --skip-systemd)
      skip_systemd="1"
      ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

if [[ ! -f "$env_file" ]]; then
  echo "missing env file: $env_file" >&2
  echo "copy env/openclaw.env.example to that path first" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "$env_file"
set +a

codex_home="${CODEX_HOME:-${HOME}/.codex}"
openclaw_state_dir="${OPENCLAW_STATE_DIR:-${HOME}/.openclaw}"
openclaw_workspace="${OPENCLAW_WORKSPACE:-${openclaw_state_dir}/workspace}"
systemd_user_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user"

mkdir -p \
  "${codex_home}/skills" \
  "${openclaw_workspace}/bin" \
  "${openclaw_workspace}/profiles/qq" \
  "${openclaw_workspace}/.openclaw" \
  "${systemd_user_dir}" \
  "$(dirname "$env_file")"

rm -rf "${codex_home}/skills/3ms-workspace-ops"
cp -a "${repo_root}/skills/3ms-workspace-ops" "${codex_home}/skills/"
copy_dir_contents "${repo_root}/scripts" "${openclaw_workspace}/bin"
copy_dir_contents "${repo_root}/runtime/profiles/qq" "${openclaw_workspace}/profiles/qq"
cp "${repo_root}/env/qq-yunxiao-deploy.conf.example" "${openclaw_workspace}/.openclaw/qq-yunxiao-deploy.conf.example"

chmod +x \
  "${repo_root}/bootstrap/render_template.py" \
  "${repo_root}/bootstrap/restore.sh" \
  "${repo_root}/bootstrap/install.sh" \
  "${repo_root}/bootstrap/doctor.sh" \
  "${openclaw_workspace}/bin/"*

python3 "${repo_root}/bootstrap/render_template.py" \
  "${repo_root}/runtime/openclaw/openclaw.json.template" \
  "${openclaw_state_dir}/openclaw.json"

if command -v openclaw >/dev/null 2>&1; then
  if ! openclaw plugins inspect qqbot-3ms-router >/dev/null 2>&1; then
    openclaw plugins install --link "${repo_root}/plugins/qqbot-3ms-router"
  fi
fi

python3 "${repo_root}/bootstrap/render_template.py" \
  "${repo_root}/runtime/systemd/openclaw-gateway.service.template" \
  "${systemd_user_dir}/openclaw-gateway.service"

if [[ "$skip_systemd" != "1" ]]; then
  systemctl --user daemon-reload
  if [[ "$restart_service" == "1" ]]; then
    systemctl --user restart openclaw-gateway
  fi
fi

echo "restored config into:"
echo "  skill: ${codex_home}/skills/3ms-workspace-ops"
echo "  workspace: ${openclaw_workspace}"
echo "  config: ${openclaw_state_dir}/openclaw.json"
echo "  service: ${systemd_user_dir}/openclaw-gateway.service"
echo "  plugin: ${repo_root}/plugins/qqbot-3ms-router"
