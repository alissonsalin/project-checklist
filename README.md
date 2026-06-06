# Architecture Change Checklist

This repository contains a custom review workflow for validating code changes before commit.

The workflow is built around:
- a custom VS Code agent (`Change Checklist Reviewer`)
- a shared checklist
- checklist-specific skills
- optional local git-hook enforcement based on the saved review report

## Repository Structure

- `.github/agents/change-checklist-reviewer.agent.md`
  - Main review agent instructions and report format.
- `.github/checklists/change-review-checklist.md`
  - Source of truth for what must be reviewed.
- `.github/skills/`
  - One skill per checklist concern (HTTP calls, DB calls, fan-out impact, cache, etc.).
- `.github/agents/references/HOOKS.md`
  - Local hook setup and behavior.
- `.github/agents/references/severity-thresholds-by-checklist.md`
  - Severity thresholds and modifiers used during review.
- `.githooks/pre-commit`
  - Pre-commit hook entrypoint.
- `scripts/checklist-gate.ps1`
  - Report-driven commit gate script.

## How It Works

1. Run `Change Checklist Reviewer` on your changes.
2. The agent evaluates changes against the checklist and relevant skills.
3. The agent writes a report to `reports/last-agent-review.md` and a timestamped history file.
4. If local hooks are enabled, commit is blocked when report verdict is `blocked`.

## Quick Start

### 0. Fetch `.github` into an existing project

From the root of your local project, run this one command:

```bash
npx degit github:alissonsalin/project-checklist/.github#master .github --force
```

This fetches the `.github` folder from this repository and writes it to your local project.

### 1. Initialize git (if needed)

```bash
git init
```

### 2. Configure hooks path

```bash
git config core.hooksPath .githooks
```

### 3. Run the review agent

Use the `Change Checklist Reviewer` agent from VS Code chat for staged, unstaged, or target commit scope.

### 4. Commit

After review report is written, commit normally. The hook reads `reports/last-agent-review.md`.

## Severity Thresholds

Severity decisions are documented in:

- `.github/agents/references/severity-thresholds-by-checklist.md`

The thresholds are organized by checklist type and include:
- `Type`
- `Description`
- `Severity`

If you need to tune severity behavior, update this reference first, then align agent and skill instructions.

## Updating Checklist Rules

1. Update `.github/checklists/change-review-checklist.md`.
2. Update or add corresponding skill under `.github/skills/`.
3. Keep report output and verdict behavior aligned in `.github/agents/change-checklist-reviewer.agent.md`.

## Notes

- This repository currently contains workflow configuration files only.
- CI should still be treated as the source of truth for mandatory enforcement in shared environments.
