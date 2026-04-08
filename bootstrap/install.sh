#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"${repo_root}/bootstrap/restore.sh" "$@"
"${repo_root}/bootstrap/doctor.sh"

