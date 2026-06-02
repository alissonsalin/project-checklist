---
name: logging-signal-and-severity
description: 'Review log quality, traceability, severity correctness, and log-noise control. Use when changes add or modify logs, log levels, structured fields, correlation IDs, retry loops, or operational alert signals.'
argument-hint: 'Describe the changed logging path and expected operational impact.'
user-invocable: true
---

# Logging Signal And Severity

Use this skill when a change introduces or modifies application logging behavior.

This skill exists to ensure logs are useful for tracing and diagnosis without flooding systems, while keeping severity levels (`info`, `warning`, `error`) aligned with operational impact.

## What to Review
- New or modified logs in request handlers, background jobs, retry paths, and failure handlers.
- Correlation and trace fields used to connect logs across services and async boundaries.
- Severity selection for success, degraded, retrying, and failure conditions.
- Structured log fields, redaction, and sensitive-data handling.
- Log volume behavior under high traffic and repeated failure conditions.

## Core Checks
1. Check traceability quality.
   - Verify logs include correlation identifiers (request id, trace id, operation id) where applicable.
   - Verify boundary logs exist at key steps: start, external call, decision points, failure, and completion.
   - Flag logs that are too vague to reconstruct user impact or service behavior.
2. Check flood and noise risk.
   - Flag per-item/per-loop logs in hot paths without sampling or rate limiting.
   - Flag repeated identical logs on retries, polling, or health checks.
   - Verify high-volume debug/info logs are bounded or disabled in production paths.
3. Check error logging quality.
   - Verify real failure conditions are logged at `error` with actionable context.
   - Ensure errors include useful dimensions (operation, dependency, status/result, correlation ids) without leaking secrets.
   - Flag swallowed exceptions or failures that do not produce an operationally visible error signal.
4. Check warning-to-error correctness.
   - Review `warning` events and promote to `error` when they represent failed business outcomes, data loss risk, or service unavailability.
   - Keep `warning` for recoverable but notable conditions that do not require immediate incident response.
5. Check info-to-error correctness.
   - Review `info` events and promote to `error` when they hide actual failures or impact critical user paths.
   - Keep `info` for expected outcomes and low-risk state transitions.
6. Check structured fields and sensitive data safety.
   - Verify logs are structured consistently for filtering and alerting.
   - Flag missing key fields that break dashboards or alert queries.
   - Flag logging of secrets, tokens, personal data, or raw payloads that should be masked.
7. Check user and service impact signals.
   - Verify logs can answer: which users/actions failed, why, and at what scope.
   - Verify logs support service-level diagnostics such as failure rate spikes, dependency errors, and saturation symptoms.

## Suggestions To Consider
- Add correlation identifiers to all request and background-job logs.
- Add boundary logs around critical operations and external dependencies.
- Use structured logging with stable field names across components.
- Add log sampling or rate limiting for repeated warnings/errors in retry loops.
- Deduplicate repeated failure logs and include occurrence counters.
- Promote misclassified `warning`/`info` entries to `error` for true failures.
- Add clear error codes/messages that map to runbooks.
- Add redaction/masking utilities for sensitive fields.
- Add alerts based on error severity and failure-rate thresholds.
- Add tests that verify important failure paths produce `error` logs.
- Add dashboards for error volume, warning-to-error ratio, and noisy logger hotspots.
- Review and remove legacy noisy logs that do not aid diagnosis.

## Red Flags
- Critical failures logged as `info` or `warning`.
- High-frequency logs inside loops without controls.
- Missing correlation ids in distributed or async flows.
- Error logs with no actionable context.
- Same error logged multiple times per retry attempt with no aggregation.
- Sensitive data exposure in log messages.
- Inconsistent field names breaking query reliability.
- Silent failure paths without `error` logs.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether the change is safe, warning-level, or blocking.
2. `Traceability Assessment`
   - Explain whether logs are sufficient to trace user flow and system behavior.
3. `Signal And Noise Assessment`
   - Explain whether log level quality and log volume are operationally appropriate.
4. `Severity Classification Assessment`
   - Explain whether `info`, `warning`, and `error` are correctly assigned.
5. `Suggestions`
   - List the smallest improvements that would materially improve logging quality.

## Reference
- Use [logging-signal-and-severity-review](./references/logging-signal-and-severity-review.md) for a compact decision guide.