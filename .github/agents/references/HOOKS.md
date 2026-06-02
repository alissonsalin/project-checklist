# Local Checklist Gate (Git Hook)

This repository includes a local pre-commit hook scaffold that blocks commits based on the saved Change Checklist Reviewer report verdict.

## Files
- `.githooks/pre-commit`
- `scripts/checklist-gate.ps1`

## Enable Locally
Run these commands once in your clone:

```bash
git config core.hooksPath .githooks
```

If the repository is not initialized yet:

```bash
git init
git config core.hooksPath .githooks
```

## Behavior
- Reads staged diff via `git diff --cached --no-color -U0` to confirm there is something to commit.
- Reads saved report from `reports/last-agent-review.md`.
- Parses `## Verdict` from the report.
- Blocks commit when verdict is `⛔ blocked`.
- Allows commit when verdict is `✅ pass` or `⚠️ pass with warnings`.

## Required Developer Flow
1. Run the `Change Checklist Reviewer` agent.
2. Ensure the agent saves report output to `reports/last-agent-review.md`.
3. Commit normally. The hook will enforce the saved verdict.

## Notes
- This gate is report-driven in its default path.
- If the report file is missing or verdict cannot be parsed, commit is blocked.
- Keep CI enforcement as source of truth for team-wide mandatory checks.