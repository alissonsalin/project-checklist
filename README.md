# Architecture Change Checklist

This repository contains a custom review workflow for validating code changes before commit.

The workflow is built around:
- a custom VS Code agent (`Change Checklist Reviewer`)
- a shared checklist
- checklist-specific skills
- saved review reports for commit-time decision support

## Repository Structure

- `.github/agents/change-checklist-reviewer.agent.md`
  - Main review agent instructions and report format.
- `.github/checklists/change-review-checklist.md`
  - Source of truth for what must be reviewed.
- `.github/skills/`
  - One skill per checklist concern (HTTP calls, DB calls, fan-out impact, cache, etc.).
- `.github/agents/references/severity-thresholds-by-checklist.md`
  - Severity thresholds and modifiers used during review.

## Checks, Purpose, and Skills

| Check | Purpose | Skill Used |
|---|---|---|
| External HTTP Calls | Validate retries, backoff, idempotency, timeout/cancellation, dependency health behavior, and observability for outbound HTTP. | external-http-calls |
| Database Calls | Validate transient retry behavior, transaction safety, timeout/cancellation, pool pressure, degradation behavior, and telemetry. | database-calls |
| Dependency Call Impact | Validate fan-out, N+1 patterns, bounded call counts, batching/caching opportunities, and cross-layer retry amplification. | dependency-call-impact |
| Comment And Impact Validation | Detect accidentally commented-out executable logic and validate downstream behavior impact of committed changes. | comment-and-impact-validation |
| Change Impact Validation | Validate cross-area impact: contracts, callers, shared utilities, behavior changes, rollout compatibility, and downstream tests. | change-impact-validation |
| Flags And Environment Variables | Validate config/flag/env safety for missing or malformed values, defaults, rollout/rollback compatibility, and visibility signals. | flag-and-env-validation |
| Scalability Validation | Validate behavior under higher load/data/batch sizes: hot paths, bottlenecks, partitioning, backpressure, and capacity signals. | scalability-validation |
| Runtime Safety And Stale Data | Validate null safety, parsing/casting assumptions, concurrency/race risks, exception handling, and stale-data decision risk. | runtime-safety-and-staleness |
| Cache Strategy And Impact | Validate cache key/TTL/invalidation design, freshness expectations, failure fallback, tenancy boundaries, and cache telemetry. | cache-strategy-and-impact |
| Resource Usage And Lifecycle | Validate CPU/memory bounds and correct acquire/release lifecycle for files, sockets, timers, subscriptions, and background work. | resource-usage-and-lifecycle |
| Logging Signal And Severity | Validate log quality, severity correctness, traceability context, flood control, and sensitive-data handling. | logging-signal-and-severity |
| Retry Mechanism | Validate bounded retries, exponential backoff with jitter, idempotency safety, nested retry multiplication risk, and retry observability. | retry-mechanism |
| Queue Consumer Processing Safety | Validate per-message log volume, dependency-call amplification, idempotency, retry and DLQ strategy, ack and commit correctness, and lag and health metrics. | queue-consumer-processing-safety |
| Exception Handling Safety | Validate exception boundaries, catch-block quality, async fault propagation, error translation consistency, fallback safety, and failure-path observability. | exception-handling-safety |
| Promise Resource Retention Safety | Validate unresolved-promise risk, exception-path cleanup, in-flight async bounds, cancellation/timeout discipline, and memory/resource retention in promise flows. | promise-resource-retention-safety |

## How It Works

1. Run `Change Checklist Reviewer` on your changes.
2. The agent evaluates changes against the checklist and relevant skills.
3. The agent writes a report to `reports/last-agent-review.md` and a timestamped history file.

## How to Use the Agent

1. Open VS Code chat.
2. Select the `Change Checklist Reviewer` agent.
3. Ask for the scope you want to review, for example:
  - `review staged changes`
  - `review unstaged changes`
  - `review commit 63e727d`
  - `review range main..feature-branch`
4. Wait for the report sections:
  - `Verdict`
  - `Risk Table`
  - `Checklist Coverage`
  - `Question for the Developer`
  - `Next Action`
5. Resolve blocking or warning findings, then commit.

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

### 2. Run the review agent

Use the `Change Checklist Reviewer` agent from VS Code chat for staged, unstaged, or target commit scope.

### 3. Commit

After review report is written, commit normally.

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
