---
name: flag-and-env-validation
description: 'Review feature flags, config flags, and environment variable changes for missing-value behavior, default safety, rollout risk, and downstream impact. Use when changes add, remove, rename, or modify flags, config keys, or environment-variable reads.'
argument-hint: 'Describe the flag or environment-variable change, how it is read, and what should happen when the value is missing or unset.'
user-invocable: true
---

# Flag And Env Validation

Use this skill when a change adds or modifies feature flags, config flags, or environment-variable reads.

This skill exists to catch failures where a missing, empty, misspelled, or partially rolled out flag or environment variable changes behavior unexpectedly, disables required protections, crashes startup, or silently enables the wrong path.

## What to Review
- New or modified feature flags, config keys, env vars, and startup settings.
- Reads from process environment, configuration providers, secret stores, and deployment manifests.
- Default values, fallback logic, parsing, and validation for optional or required settings.
- Behavior when values are missing, empty, malformed, or not yet deployed in all environments.
- Rollout, rollback, and mixed-environment compatibility for renamed or removed settings.

## Core Checks
1. Check presence and ownership.
   - Identify every new or renamed flag or env var and where it must be set.
   - Verify ownership is clear across code, deployment config, docs, and runtime environment.
   - Flag reads that depend on implicit operator knowledge instead of declared configuration.
2. Check missing-value behavior.
   - Verify what happens when the flag or env var is unset, empty, whitespace, or absent in one environment.
   - Flag null dereference, parse failure, or startup crash paths caused by missing values.
   - Prefer explicit defaults, validation, or fail-fast messages over silent fallback to unsafe behavior.
3. Check default safety.
   - Verify defaults are safe for correctness, security, cost, and availability.
   - Flag defaults that accidentally enable unfinished behavior, disable protection, or widen access.
   - Check whether the default is appropriate for local, test, staging, and production environments.
4. Check parsing and value compatibility.
   - Verify boolean, enum, numeric, duration, and URL parsing handles malformed or unexpected values safely.
   - Flag case-sensitivity, spelling, and format assumptions that make rollout fragile.
   - Check compatibility when old and new values may coexist during deployment.
5. Check rollout and downstream impact.
   - Verify renamed, removed, or split flags remain compatible during rollout and rollback.
   - Check affected callers, jobs, controllers, or background workers that read the same setting.
   - Flag changes where one environment or service can observe a different behavior because the value is not set consistently.
6. Check observability and test evidence.
   - Ensure startup validation, logs, metrics, or health signals make missing or invalid settings visible.
   - Prefer tests for missing, empty, malformed, and default-value behavior.
   - Flag changes where config mistakes would only surface in production with weak diagnostics.

## Suggestions To Consider
- Add explicit validation for required flags and env vars at startup.
- Add safe defaults for optional settings and document the intended fallback behavior.
- Add compatibility shims when renaming flags or env vars across rolling deployments.
- Add tests for missing, empty, malformed, and unexpected values.
- Add structured logs or health checks that surface invalid configuration clearly.
- Update deployment manifests, sample env files, and runbooks alongside code changes.
- Prefer typed configuration binding with validation over scattered raw environment reads.

## Red Flags
- New env var read with no default, validation, or deployment update.
- Missing value causes crash, unsafe fallback, or silent behavior drift.
- Default value enables risky code paths or disables safety checks.
- Renamed flag breaks old deployments or rollback because both names are not supported.
- Parsing assumes valid input with no error handling.
- Different services or jobs depend on the same setting but rollout is not coordinated.
- No telemetry or tests for configuration failure paths.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether the flag or environment-variable change is safe, warning-level, or blocking.
2. `Configuration Assessment`
   - Explain whether presence, defaults, parsing, and validation are safe.
3. `Missing-Value Impact`
   - Explain the runtime effect when the value is unset, empty, malformed, or partially rolled out.
4. `Rollout Assessment`
   - Explain compatibility across environments, services, and rollback scenarios.
5. `Suggestions`
   - List the smallest improvements that would materially reduce configuration risk.

## Reference
- Use [flag-and-env-validation-review](./references/flag-and-env-validation-review.md) for a compact decision guide.