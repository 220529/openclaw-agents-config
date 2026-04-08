---
name: 3ms-workspace-ops
description: Operate a 3ms-style workspace for OpenClaw agents. Use when Codex needs to interpret or execute the fixed Chinese commands for checking upstream changes, syncing child repos, pulling the main repo, or triggering the separately configured Yunxiao deployment API. Prefer the exact commands listed in `references/intent-map.md`.
---

# 3ms Workspace Ops

## Overview

Handle the fixed set of 3ms Git workflows for the active agent workspace. Treat this skill as the routing and execution contract for 3ms requests; do not guess whether the user means `upstream` or `origin`.

## Quick Start

1. Read [references/intent-map.md](references/intent-map.md) to map the user phrase to a canonical intent.
2. Prefer the installed `qq-3ms-intent` entrypoint as the unified executor for these requests.
   - For exact fixed commands, pass the exact Chinese command text verbatim, for example `qq-3ms-intent "拉取上游仓库并部署"`.
   - For the branch template, pass the full command text, for example `qq-3ms-intent "切分支 v0.0.3"`.
3. Let `qq-3ms-intent` delegate internally to:
   - `/root/.openclaw/workspace/bin/qq-upstream-status`
   - `/root/.openclaw/workspace/bin/qq-update-workspace`
   when they already cover the intent.
4. If the chosen script prints `QQ_RESULT=` or `QQ_DETAIL=`, reuse those lines directly in the QQ reply.
5. Keep QQ replies short. Default to 1 or 2 lines unless the user explicitly asks for details.
6. Treat `System: [..] Exec completed ...` blocks as historical context by default. If the user issues a fresh action command in the same message, execute the intent again instead of reusing the old summary.

## Execution Rules

- Keep `upstream` and `origin` separate.
  - `upstream` means the GitHub upstream of `sub2api-main`.
  - `origin` means the user's own remote branch.
- Only auto-execute the exact QQ commands listed in `references/intent-map.md`.
  - When calling `qq-3ms-intent` from a chat runtime, pass the exact fixed command text verbatim; do not manually translate it to a numeric intent id.
  - If the user sends old jargon or a similar but non-exact phrase such as `更新下吧`, `拉一下主项目 origin`, or `同步一下上游`, do not execute it directly.
  - When one fixed command is the clear high-confidence match, reply with that candidate and ask for exact confirmation.
  - When multiple fixed commands are plausible, offer 2 to 3 exact fixed-command options and wait.
  - Keep `upstream` vs `origin` ambiguous cases as clarification-first; do not collapse them into one suggestion unless the intent is genuinely clear.
  - Prefer the recommended short commands from `references/intent-map.md` when suggesting a command back to the user.
- Scope the operation correctly.
  - `主项目` means the configured `sub2api-main` repo.
  - `子项目` means the configured backend and frontend child repos.
- Reuse the current branch of `sub2api-main` as the target branch unless the user explicitly says otherwise.
- Apply the current workspace policy:
  - Dirty worktrees in scope may be discarded before continuing.
  - Deployments default to out of scope. Only the exact fixed deploy commands listed in `intent-map.md` may call the separately configured Yunxiao API.
- Stop immediately on merge conflicts, Git identity issues, or push failures. Reply with the exact failure point.

## References

- Read [references/intent-map.md](references/intent-map.md) for phrase routing, preferred executor, and manual fallback steps.
