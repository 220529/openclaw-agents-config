# OpenClaw Agents Config

Versioned configuration and recovery assets for OpenClaw agents.

This repository is not just a skill pack. It is the source repository for:

- skills
- agent-facing execution scripts
- runtime templates
- env examples
- bootstrap and recovery scripts

Current included agent set:

- QQ / `小龙虾` / 3ms workspace workflows

## Layout

```text
skills/      Agent skills and references
scripts/     Executable helpers copied into the OpenClaw workspace
plugins/     Local OpenClaw plugins linked into the runtime
runtime/     Templates for OpenClaw config, profiles, and systemd units
env/         Non-secret examples and config templates
bootstrap/   Restore, install, and doctor scripts
docs/        Optional architecture notes
```

## Secrets

Do not commit live secrets.

Keep real values outside the repository, for example in:

- `~/.config/openclaw/openclaw.env`
- `${OPENCLAW_STATE_DIR}/qq-yunxiao-deploy.conf`
- token files referenced by those configs

The repository only keeps examples and templates.

## Restore Flow

1. Clone this repository.
2. Run `bootstrap/init-secrets.sh`.
3. Fill required secrets and paths in the generated local files.
4. Run `bootstrap/secrets-check.sh`.
5. Run `bootstrap/restore.sh`.
6. Run `bootstrap/doctor.sh`.
7. If needed, restart the gateway with `bootstrap/install.sh --restart`.

Important machine-specific values:

- `OPENCLAW_NODE_BIN`
- `OPENCLAW_NODE_MODULES_DIR`

These usually come from the machine's global Node/OpenClaw installation.

## Validation

- `bootstrap/init-secrets.sh`
  - creates local env/config files from repository examples with safe permissions
- `bootstrap/secrets-check.sh`
  - validates local env and deploy secrets before restore
- `bootstrap/doctor.sh`
  - validates rendered config, scripts, and installed file layout after restore

## Docs

- `docs/migration.md`
  - end-to-end migration and rebuild checklist

## Current Contract

- Action commands: 10
- Help commands: 2
- Historical long phrases: retired, confirmation only
