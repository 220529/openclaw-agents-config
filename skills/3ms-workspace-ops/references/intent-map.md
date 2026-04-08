# 3ms Intent Map

Use this file to map QQ phrases to canonical intents for `/root/3ms`.

## Canonical Intents

| ID | Canonical intent | Meaning | Preferred executor |
| --- | --- | --- | --- |
| `1` | `check-upstream-status` | Check whether `sub2api-main` is behind `upstream/main` | `/root/.openclaw/workspace/bin/qq-3ms-intent 1` |
| `2` | `merge-upstream-main` | Merge `upstream/main` into `sub2api-main`, do not push, do not touch child repos | `/root/.openclaw/workspace/bin/qq-3ms-intent 2` |
| `3` | `sync-children` | Sync `sub2api-main` code into `3ms_backend` and `3ms_frontend`, do not push | `/root/.openclaw/workspace/bin/qq-3ms-intent 3` |
| `4` | `merge-upstream-main-push` | Run intent `2`, then push `sub2api-main` | `/root/.openclaw/workspace/bin/qq-3ms-intent 4` |
| `5` | `sync-children-push` | Run intent `3`, then commit and push changed child repos | `/root/.openclaw/workspace/bin/qq-3ms-intent 5` |
| `6` | `update-all` | Run `1`, then full upstream merge + child sync + commit/push, no deploy | `/root/.openclaw/workspace/bin/qq-3ms-intent 6` |
| `7` | `pull-main-origin` | Pull `origin/<current-branch>` into local `sub2api-main` only | `/root/.openclaw/workspace/bin/qq-3ms-intent 7` |
| `8` | `pull-main-origin-sync-children-push` | Run `7`, then `5` | `/root/.openclaw/workspace/bin/qq-3ms-intent 8` |
| `9` | `deploy-yunxiao` | Trigger the separately configured Yunxiao deployment API | `/root/.openclaw/workspace/bin/qq-3ms-intent 9` |
| `10` | `update-all-deploy-yunxiao` | Run `6`, then deploy the changed child repos for the current branch; if no update, do not deploy | `/root/.openclaw/workspace/bin/qq-3ms-intent 10` |
| `11` | `check-main-branch` | Show the current local branch of `sub2api-main`; child repos are assumed to follow it | `/root/.openclaw/workspace/bin/qq-3ms-intent 11` |
| `12` | `switch-workspace-branch` | Switch all three repos to the requested branch; if missing locally, fetch from `origin` and create the local tracking branch | `/root/.openclaw/workspace/bin/qq-3ms-intent 12 <branch>` |
| `13` | `check-deploy-readiness` | Check whether the current branch is ready for Yunxiao deploy: child repo remote branches exist and deploy config follows the current branch | `/root/.openclaw/workspace/bin/qq-3ms-intent 13` |
| `14` | `list-main-branches` | List the current branch plus local and `origin` branches of `sub2api-main` | `/root/.openclaw/workspace/bin/qq-3ms-intent 14` |
| `15` | `list-command-summary` | Show the recommended short command set and point to the full fixed-command list | `/root/.openclaw/workspace/bin/qq-3ms-intent 15` |
| `16` | `list-fixed-commands` | List all fixed QQ commands/templates that the 3ms workspace bot will execute directly, grouped by category | `/root/.openclaw/workspace/bin/qq-3ms-intent 16` |
| `17` | `pull-main-origin-sync-children-push-deploy-yunxiao` | Run `8`, then deploy the changed child repos for the current branch; if no child repo changed, do not deploy | `/root/.openclaw/workspace/bin/qq-3ms-intent 17` |

## Public QQ Commands

These are the 10 public commands users should remember first.

- `看上游更新`
- `同步更新`
- `拉取上游仓库并部署`
- `拉取主项目`
- `拉取主项目并部署`
- `看分支`
- `列分支`
- `切分支 <branch>`
- `部署前检查`
- `执行部署`

## Exact Action QQ Commands

| Exact phrase | Route |
| --- | --- |
| `看上游更新` | `1` |
| `同步更新` | `6` |
| `拉取上游仓库并部署` | `10` |
| `拉取主项目` | `7` |
| `拉取主项目并部署` | `17` |
| `看分支` | `11` |
| `列分支` | `14` |
| `切分支 <branch>` | `12` |
| `部署前检查` | `13` |
| `执行部署` | `9` |

## Exact Help QQ Commands

| Exact phrase | Route |
| --- | --- |
| `口令` | `15` |
| `列出所有口令` | `16` |

## Retired Long Phrases

These historical phrases are no longer exact executable commands. Treat them as non-exact input and route by confirmation only.

- Old long phrases should be rewritten to the current short commands:
  - 上游检查类 -> `看上游更新`
  - 主项目拉取类 -> `拉取主项目`
  - 主项目拉取后部署类 -> `拉取主项目并部署`
  - 部署类 -> `执行部署`
  - 分支查看类 -> `看分支`
  - 分支切换类 -> `切分支 <branch>`
  - 部署检查类 -> `部署前检查`
  - 分支列表类 -> `列分支`
- Old intermediate workflows like merge-only, sync-only, push-only, or “同步子项目后上传到云效” are fully retired.
  - Do not execute them directly.
  - Tell the user the long-form intermediate workflow has been retired and offer the nearest public command options.

## Phrase Mapping

- Only auto-route the exact commands listed in the tables above.
- For route `12`, only auto-route when the whole message matches the fixed template `切分支 <branch>` and `<branch>` is non-empty.
- If the user sends a similar but non-exact phrase, do not execute it directly.
  - If one fixed command is the clear high-confidence match, suggest that exact command and ask the user to resend it verbatim.
  - If there are multiple plausible fixed commands, list 2 to 3 candidate exact commands and ask the user to choose one.
  - If the phrase only misses the branch template but the branch name is clear, suggest the fully expanded exact command `切分支 <branch>`.
  - Prefer the 10 public commands above; do not suggest retired long phrases back to the user as the exact command to resend.
  - Example ambiguous phrases:
    - `看看上游有没有更新`
    - `把 upstream 合到主项目`
    - `同步子项目`
    - `把 upstream 合到主项目并 push`
    - `同步子项目并 push`
    - `更新下吧`
    - `拉一下主项目 origin`
    - `拉主项目 origin 并同步子项目后 push`
    - `拉一下主项目`
    - `拉一下主项目的代码`
    - `合一下上游`
    - `同步一下上游`
    - `8`
    - `7+5`
    - `部署一下`
    - `点一下部署`
    - `三个项目使用哪个分支`
    - `现在三个项目在哪个分支`
    - `切到 v0.0.2`
    - `切换到 v0.0.2`
    - `切分支到 v0.0.2`
    - `这个分支能不能部署`
- If the user is ambiguous between `upstream` and `origin`, ask a short clarification instead of guessing.
- Recommended confirmation mappings:
  - `看看上游有没有更新` -> `看上游更新`
  - `检查上游仓库更新` -> `看上游更新`
  - `把 upstream 合到主项目` / `合一下上游` / `同步一下上游` -> ask the user to choose between `同步更新` and `拉取上游仓库并部署`
  - `同步子项目` -> ask the user to choose the nearest public command; do not execute directly
  - `把 upstream 合到主项目并 push` -> ask the user to choose between `同步更新` and `拉取上游仓库并部署`
  - `同步子项目并 push` -> ask the user to choose the nearest public command; do not execute directly
  - `拉一下主项目 origin` / `拉一下主项目` / `拉一下主项目的代码` -> `拉取主项目`
  - `主项目拉取云效最新代码` -> `拉取主项目`
  - `拉主项目 origin 并同步子项目后 push` -> ask the user to choose between `拉取主项目` and `拉取主项目并部署`
  - `拉主项目 origin 并同步子项目后 push 再部署` -> `拉取主项目并部署`
  - `执行云效部署` / `部署一下` / `点一下部署` -> `执行部署`
  - `查看主项目当前分支` / `查看主项目分支` / `查看分支` / `查看三个项目当前分支` -> `看分支`
  - `三个项目使用哪个分支` / `现在三个项目在哪个分支` -> `看分支`
  - `切换三个项目到分支 v0.0.2` -> `切分支 v0.0.2`
  - `切到 v0.0.2` / `切换到 v0.0.2` / `切分支到 v0.0.2` -> `切分支 v0.0.2`
  - `检查当前分支是否可部署` / `检查部署条件` / `帮我判断现在是否满足云效部署条件` / `这个分支能不能部署` -> `部署前检查`
  - `列出主项目所有分支` / `列出三个项目所有分支` / `列出分支` / `现在有哪些分支` / `现在有哪些分支？` -> `列分支`
  - `更新下吧` / `有更新就更新掉` -> ask the user to choose between `同步更新` and `拉取主项目`

## Manual Workflows

Use these workflows only when `qq-3ms-intent` is unavailable or the user explicitly asks for the raw Git steps.

### Shared Rules

- Scope destructive cleanup to the repos involved in the chosen intent.
- Default branch is `git -C /root/3ms/sub2api-main branch --show-current`.
- Stop on conflicts or push failures and reply with the failure point.
- Do not deploy, except for intents `9`, `10`, and `17`, which use the dedicated Yunxiao API script.

### Intent `2`: merge-upstream-main

1. Discard dirty state in `sub2api-main` if current workspace policy says to do so.
2. `git -C /root/3ms/sub2api-main fetch upstream --prune`
3. `git -C /root/3ms/sub2api-main merge --no-ff --no-edit upstream/main`
4. Report success or conflict. Do not push.

### Intent `3`: sync-children

1. Ensure `3ms_backend` and `3ms_frontend` are on the same branch as `sub2api-main`.
2. Discard dirty state in the child repos if current workspace policy says to do so.
3. Run:
   - `/root/3ms/sub2api-main/scripts/sync-backend.sh`
   - `/root/3ms/sub2api-main/scripts/sync-frontend.sh`
4. Report which child repos changed. Do not push.

### Intent `4`: merge-upstream-main-push

Run intent `2`, then:

1. `git -C /root/3ms/sub2api-main push origin <current-branch>`
2. Report whether the push succeeded.

### Intent `5`: sync-children-push

Run intent `3`, then for each changed child repo:

1. `git -C <repo> add -A`
2. `git -C <repo> commit -m "chore: sync from sub2api-main <main-short-sha>"`
3. `git -C <repo> push origin <current-branch>`

If a child repo has no changes, reply that it had no sync diff.

### Intent `7`: pull-main-origin

1. Discard dirty state in `sub2api-main` if current workspace policy says to do so.
2. `git -C /root/3ms/sub2api-main pull --no-rebase --no-edit origin <current-branch>`
3. Report the new HEAD or that it was already up to date.

### Intent `8`: pull-main-origin-sync-children-push

Run intent `7`, then run intent `5`.

### Intent `9`: deploy-yunxiao

1. Run `/root/.openclaw/workspace/bin/qq-yunxiao-deploy`
2. Reuse the script's `QQ_RESULT` and `QQ_DETAIL`.
3. If Yunxiao PAT, `organizationId`, `pipelineId`, or target action config is missing, stop and reply with the missing configuration item.

### Intent `10`: update-all-deploy-yunxiao

1. Run intent `6`.
2. If `RESULT=up_to_date`, stop and reuse the update reply. Do not deploy.
3. If `RESULT=updated`, inspect `BACKEND_CHANGED` and `FRONTEND_CHANGED`.
4. Trigger `/root/.openclaw/workspace/bin/qq-yunxiao-deploy` only for the child repos that actually changed and were pushed.
5. Pass the current `sub2api-main` branch as the Yunxiao branch parameter.

### Intent `17`: pull-main-origin-sync-children-push-deploy-yunxiao

1. Run intent `8`.
2. If both child repos have no sync diff, stop and reuse the sync reply. Do not deploy.
3. If one or more child repos were committed and pushed, trigger `/root/.openclaw/workspace/bin/qq-yunxiao-deploy` only for those pushed child repos.
4. Pass the current `sub2api-main` branch as the Yunxiao branch parameter.

### Intent `11`: check-main-branch

1. Read the current local branch of `/root/3ms/sub2api-main`.
2. Reply with that branch directly.
3. Assume `3ms_backend` and `3ms_frontend` follow the main repo branch unless the user explicitly asks to inspect them separately.

### Intent `12`: switch-workspace-branch

1. Validate the requested branch name.
2. Scope the operation to:
   - `/root/3ms/sub2api-main`
   - `/root/3ms/3ms_backend`
   - `/root/3ms/3ms_frontend`
3. Discard dirty state in those repos if current workspace policy says to do so.
4. For each repo:
   - If the local branch exists, check it out.
   - Otherwise, fetch `origin/<branch>`.
   - If fetch succeeds, create or reset the local branch to track `origin/<branch>`.
5. If any repo still lacks that branch after fetch, stop and reply which repo is missing it.
6. Reply with the switched branch, and mention any repos that had to fetch the branch from `origin`.

### Intent `13`: check-deploy-readiness

1. Read the current local branch of `/root/3ms/sub2api-main`.
2. Read the Yunxiao deploy config from `/root/.openclaw/qq-yunxiao-deploy.conf` unless overridden.
3. Check:
   - `3ms_backend` target is enabled, has a pipeline id, and uses current branch mode.
   - `3ms_frontend` target is enabled, has a pipeline id, and uses current branch mode.
4. Verify that `origin/<current-branch>` exists for:
   - `/root/3ms/3ms_backend`
   - `/root/3ms/3ms_frontend`
5. If all checks pass, reply that the current branch can be deployed directly.
6. Otherwise reply that it is not ready yet, and list the missing remote branches or config gaps.

### Intent `14`: list-main-branches

1. Read the current local branch of `/root/3ms/sub2api-main`.
2. List local branches from `refs/heads`.
3. List remote branches from `refs/remotes/origin`, excluding `origin/HEAD`.
4. Reply with the current branch plus the local and origin branch lists.
5. Treat `列出三个项目所有分支` as a shorthand for the main repo branch list, because child repos normally follow the main repo branch.

### Intent `15`: list-command-summary

1. Reply with the 10 public commands that users should remember first.
2. Put each recommended command on its own detail line.
3. Point the user to `列出所有口令` for the full grouped list.

### Intent `16`: list-fixed-commands

1. List every fixed QQ command/template that is currently allowed to auto-execute.
2. Separate the 10 action commands from the 2 help commands.
3. Reply with the total count and one line stating that historical long phrases no longer auto-execute.

## QQ Reply Contract

- Prefer script-produced `QQ_RESULT` and `QQ_DETAIL`.
- For non-exact but high-confidence phrases that are not executed yet, prefer one of these short confirmation replies:
  - Single candidate:
    - `QQ_RESULT=你是不是要执行：拉取主项目？`
    - `QQ_DETAIL=如果是，直接回复这句就行。`
  - Multiple candidates:
    - `QQ_RESULT=这句我先不直接执行。`
    - `QQ_DETAIL_1=你要的是下面哪一句固定口令？`
    - `QQ_DETAIL_2=1. 同步更新`
    - `QQ_DETAIL_3=2. 拉取主项目`
  - `upstream` / `origin` ambiguity:
    - `QQ_RESULT=你这句里没说明是上游还是云效远端。`
    - `QQ_DETAIL=请直接发固定口令，我再执行。`
- If a script prints `QQ_DETAIL_1`, `QQ_DETAIL_2`, ...:
  - append those detail lines in numeric order after `QQ_RESULT`
  - do not collapse them back into one long line
- Otherwise keep replies in this shape:
  - Success: 1 short result line, 1 short detail line.
  - Failure: 1 short error line, 1 short failure-point line.
- For intent `11`, prefer:
  - `QQ_RESULT=主项目当前分支是 v0.0.2。`
  - `QQ_DETAIL=子项目默认跟随主项目分支。`
- For intent `12`, prefer:
  - `QQ_RESULT=三个项目已切换到分支 v0.0.2。`
  - `QQ_DETAIL=sub2api-main、3ms_backend、3ms_frontend：v0.0.2。`
  - If needed, append `已从 origin 拉取缺失分支：...`
- For intent `13`, prefer:
  - `QQ_RESULT=当前分支 v0.0.2 可以直接触发云效部署。`
  - `QQ_DETAIL=3ms_backend、3ms_frontend 远端已存在同名分支；云效已配置按当前分支部署。`
  - or if not ready: `QQ_RESULT=当前分支 v0.0.2 暂时不能直接触发云效部署。` plus one detail line listing missing branches or config issues
- For intent `14`, prefer:
  - `QQ_RESULT=主项目当前分支是 v0.0.2。`
  - `QQ_DETAIL=本地：main、v0.0.2；origin：main、v0.0.1、v0.0.2。`
- For intent `15`, prefer:
  - `QQ_RESULT=公开主口令 10 条。`
  - `QQ_DETAIL_1=看上游更新`
  - `QQ_DETAIL_2=同步更新`
  - `QQ_DETAIL_3=拉取上游仓库并部署`
  - `QQ_DETAIL_4=拉取主项目`
  - `QQ_DETAIL_5=拉取主项目并部署`
  - `QQ_DETAIL_6=看分支`
  - `QQ_DETAIL_7=列分支`
  - `QQ_DETAIL_8=切分支 <branch>`
  - `QQ_DETAIL_9=部署前检查`
  - `QQ_DETAIL_10=执行部署`
  - `QQ_DETAIL_11=完整列表发：列出所有口令`
- For intent `16`, prefer:
  - `QQ_RESULT=当前固定口令共 12 条。`
  - `QQ_DETAIL_1=动作口令：看上游更新 / 同步更新 / 拉取上游仓库并部署 / 拉取主项目 / 拉取主项目并部署`
  - `QQ_DETAIL_2=动作口令：看分支 / 列分支 / 切分支 <branch> / 部署前检查 / 执行部署`
  - `QQ_DETAIL_3=帮助口令：口令 / 列出所有口令`
  - `QQ_DETAIL_4=历史长句已下线，只做候选建议，不再直接执行。`
  - `QQ_DETAIL_4=历史长句已下线，只做候选建议，不再直接执行。`
- Do not narrate the execution process.
- If the incoming message also contains an auto-inserted `System: [..] Exec completed ...` block:
  - Treat it as historical context unless the user explicitly asks to interpret that output.
  - If the user issues a fresh command, rerun the mapped intent instead of repeating the old result.
