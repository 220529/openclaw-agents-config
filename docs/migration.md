# Migration Guide

This repository is the recovery source for the current OpenClaw agent setup.

## What Must Be Preserved

Repository-managed:

- `skills/`
- `scripts/`
- `runtime/`
- `env/*.example`
- `bootstrap/`

Local-only secrets and machine values:

- `~/.config/openclaw/openclaw.env`
- `${OPENCLAW_STATE_DIR}/qq-yunxiao-deploy.conf`
- token files referenced by those configs

Do not rely on preserving:

- logs
- agent sessions
- qqbot caches
- old backup files

## Rebuild on a New Machine

1. Install Node and OpenClaw globally.
2. Install or restore the 3ms repos into the target workspace path.
3. Clone this repository.
4. Run:

```bash
cd ~/openclaw-agents-config
./bootstrap/init-secrets.sh
```

5. Fill the generated local files:
   - `~/.config/openclaw/openclaw.env`
   - `${OPENCLAW_STATE_DIR}/qq-yunxiao-deploy.conf`
6. Validate secrets:

```bash
./bootstrap/secrets-check.sh
```

7. Restore files:

```bash
./bootstrap/restore.sh --restart
```

8. Verify:

```bash
./bootstrap/doctor.sh
curl -fsS http://127.0.0.1:18789/health
```

## GitHub Branches

Recommended branch setup:

- default branch: `main`
- old `master`: remove after GitHub default branch has been switched to `main`

## Current Runtime Assumptions

- OpenClaw state dir defaults to `~/.openclaw`
- local env file defaults to `~/.config/openclaw/openclaw.env`
- gateway runs as `systemd --user`
- current public contract is 10 action commands + 2 help commands
