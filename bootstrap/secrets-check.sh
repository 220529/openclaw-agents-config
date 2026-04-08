#!/usr/bin/env bash
set -euo pipefail

env_file="${OPENCLAW_CONFIG_ENV:-${HOME}/.config/openclaw/openclaw.env}"

if [[ ! -f "$env_file" ]]; then
  echo "missing env file: $env_file" >&2
  echo "copy env/openclaw.env.example to that path first" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "$env_file"
set +a

missing=0

require_nonempty() {
  local name="$1"
  local value="${!name:-}"
  if [[ -z "$value" ]]; then
    echo "missing env: $name" >&2
    missing=1
  fi
}

require_path_exists() {
  local label="$1"
  local path="$2"
  if [[ ! -e "$path" ]]; then
    echo "missing path for ${label}: ${path}" >&2
    missing=1
  fi
}

require_nonempty OPENCLAW_STATE_DIR
require_nonempty OPENCLAW_WORKSPACE
require_nonempty CODEX_HOME
require_nonempty OPENCLAW_GATEWAY_PORT
require_nonempty OPENCLAW_GATEWAY_TOKEN
require_nonempty OPENCLAW_MODEL_PRIMARY
require_nonempty OPENAI_BASE_URL
require_nonempty OPENCLAW_NODE_BIN
require_nonempty OPENCLAW_NODE_MODULES_DIR
require_nonempty QQBOT_APP_ID
require_nonempty QQBOT_CLIENT_SECRET

if [[ -n "${OPENCLAW_NODE_BIN:-}" ]]; then
  require_path_exists "OPENCLAW_NODE_BIN" "${OPENCLAW_NODE_BIN}"
fi
if [[ -n "${OPENCLAW_NODE_MODULES_DIR:-}" ]]; then
  require_path_exists "OPENCLAW_NODE_MODULES_DIR" "${OPENCLAW_NODE_MODULES_DIR}"
fi

deploy_config="${QQ_YUNXIAO_DEPLOY_CONFIG:-${OPENCLAW_STATE_DIR:-${HOME}/.openclaw}/qq-yunxiao-deploy.conf}"
if [[ -f "$deploy_config" ]]; then
  # shellcheck disable=SC1090
  . "$deploy_config"
  if [[ -z "${YUNXIAO_ORGANIZATION_ID:-}" ]]; then
    echo "missing deploy config: YUNXIAO_ORGANIZATION_ID" >&2
    missing=1
  fi
  if [[ -n "${YUNXIAO_API_TOKEN_FILE:-}" && ! -r "${YUNXIAO_API_TOKEN_FILE}" ]]; then
    echo "missing deploy token file: ${YUNXIAO_API_TOKEN_FILE}" >&2
    missing=1
  fi
else
  echo "deploy config not found (optional): $deploy_config" >&2
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo "secrets-check ok"
