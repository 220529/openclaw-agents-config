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
runtime/     Templates for OpenClaw config, profiles, and systemd units
env/         Non-secret examples and config templates
bootstrap/   Restore, install, and doctor scripts
docs/        Optional architecture notes
```

## Secrets

Do not commit live secrets.

Keep real values outside the repository, for example in:

- `~/.config/openclaw/openclaw.env`
- `${OPENCLAW_HOME}/qq-yunxiao-deploy.conf`
- token files referenced by those configs

The repository only keeps examples and templates.

## Restore Flow

1. Clone this repository.
2. Create `~/.config/openclaw/openclaw.env` from `env/openclaw.env.example`.
3. Fill required secrets and paths.
4. Run `bootstrap/restore.sh`.
5. Run `bootstrap/doctor.sh`.
6. If needed, restart the gateway with `bootstrap/install.sh --restart`.

## Current Contract

- Action commands: 10
- Help commands: 2
- Historical long phrases: retired, confirmation only

