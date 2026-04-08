#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_target="${OPENCLAW_CONFIG_ENV:-${HOME}/.config/openclaw/openclaw.env}"
state_dir_default="${OPENCLAW_STATE_DIR:-${HOME}/.openclaw}"
deploy_target="${QQ_YUNXIAO_DEPLOY_CONFIG:-${state_dir_default}/qq-yunxiao-deploy.conf}"
force="0"

for arg in "$@"; do
  case "$arg" in
    --force)
      force="1"
      ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

copy_once() {
  local src="$1"
  local dest="$2"
  if [[ -e "$dest" && "$force" != "1" ]]; then
    echo "skip existing: $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  chmod 600 "$dest"
  echo "wrote: $dest"
}

copy_once "${repo_root}/env/openclaw.env.example" "$env_target"
copy_once "${repo_root}/env/qq-yunxiao-deploy.conf.example" "$deploy_target"

echo
echo "next:"
echo "  1. edit $env_target"
echo "  2. edit $deploy_target"
echo "  3. run bootstrap/secrets-check.sh"

