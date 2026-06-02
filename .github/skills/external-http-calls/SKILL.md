---
name: external-http-calls
description: 'Review outbound HTTP calls for retries, backoff, idempotency, timeouts, and dependency health impact. Use when changes add or modify external API calls, HTTP clients, resilience policies, or health-check behavior.'
argument-hint: 'Describe the changed outbound HTTP call or the diff scope to review.'
user-invocable: true
---

# External HTTP Calls

Use this skill when a change adds, removes, or modifies any outbound HTTP call.

This skill exists to prevent fragile integrations from causing retry storms, latency amplification, or unnecessary application health degradation.

## What to Review
- New or modified HTTP clients, SDK wrappers, service adapters, or gateway code.
- Retry configuration, resilience middleware, circuit breakers, and timeout settings.
- Startup checks, readiness checks, liveness checks, and background jobs that depend on external services.
- Telemetry changes for external calls, including metrics, logs, and tracing.

## Core Checks
1. Identify the call path.
   - Find where the outbound request is built and executed.
   - Confirm whether the change affects a single call site or a shared client used by multiple flows.
2. Verify retries exist only where safe.
   - Accept retries for transient failures such as connect failures, timeouts, `429`, and `5xx`.
   - Flag retries for validation errors, authentication failures, authorization failures, or other permanent failures.
   - Flag retries on non-idempotent operations unless the design includes idempotency keys or equivalent safeguards.
3. Verify backoff quality.
   - Require bounded exponential backoff instead of immediate or constant tight-loop retries.
   - Prefer jitter so multiple instances do not synchronize retry spikes.
   - Require a retry cap, total time budget, or both.
   - Check whether `Retry-After` is honored when the downstream service provides it.
4. Verify timeout and cancellation behavior.
   - Ensure each call has an explicit timeout or deadline.
   - Ensure retries cannot exceed the caller's end-to-end latency budget.
   - Ensure cancellation propagates so abandoned requests do not continue consuming resources.
5. Protect application health.
   - Check whether downstream failures can incorrectly fail readiness or liveness.
   - Prefer degraded mode, cached data, queues, fallbacks, or feature isolation for non-critical dependencies.
   - If a dependency is critical, require the unhealthy behavior to be explicit, justified, and documented.
   - Flag startup paths that block indefinitely on an external service.
6. Check observability.
   - Ensure logs distinguish first failure from retried failure and final failure.
   - Ensure metrics or tracing expose latency, failure rate, retry count, and timeout rate.
   - Flag patterns that could hide retry storms or dependency saturation.

## Suggestions to Consider
- Add a circuit breaker when repeated failures would otherwise amplify latency or load.
- Add concurrency limits or bulkheads so one unstable dependency cannot starve the whole process.
- Add idempotency keys for retried write operations.
- Separate readiness from liveness so transient dependency outages do not trigger restart loops.
- Add fallback behavior for optional integrations.
- Cap retry delay and overall request budget to protect user-facing latency.
- Honor upstream rate-limit signals and `Retry-After` headers.
- Add tests that simulate timeouts, `429`, and repeated `5xx` responses.
- Add dashboards or alerts for elevated retries, downstream latency, and circuit-breaker open events.
- Centralize retry policy in a shared client so call sites do not drift.

## Red Flags
- Infinite retries or retries without a max attempt count.
- Immediate retries with no backoff or no jitter.
- Retries for `400`, `401`, `403`, or domain validation errors.
- Health checks that depend on optional third-party APIs.
- Startup failure because a non-critical dependency is temporarily unavailable.
- Nested retries across layers that multiply request count.
- Missing timeout on an outbound call.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether the change is safe, warning-level, or blocking.
2. `Retry Assessment`
   - Explain whether retries are present, correctly scoped, and bounded.
3. `Backoff Assessment`
   - Explain whether backoff, jitter, and total budget are appropriate.
4. `Health Impact`
   - Explain whether the dependency can move the app into an unhealthy state and whether that is justified.
5. `Suggestions`
   - List the smallest improvements that would materially reduce integration risk.

## Reference
- Use [external-http-call-review](./references/external-http-call-review.md) for a compact decision guide.