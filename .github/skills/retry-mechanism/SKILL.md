---
name: retry-mechanism
description: 'Review retry logic for infinite loops, resource amplification, call spike risk, backoff quality, idempotency, and observability. Use when changes add or modify retry policies, resilience wrappers, backoff configuration, circuit breakers, or any flow that can repeat a failed operation.'
argument-hint: 'Describe the changed retry logic, resilience wrapper, or the diff scope to review.'
user-invocable: true
---

# Retry Mechanism

Use this skill when a change adds, removes, or modifies any retry behavior — including explicit retry loops, resilience libraries, background job re-queuing, SDK-level retry configuration, circuit breakers, or backoff strategies.

This skill exists to prevent retry logic from becoming a source of infinite loops, resource amplification, call spikes to external services, and cascading failures that are harder to detect than the original fault.

## What to Review
- New or modified retry loops, policy objects, resilience wrappers, and middleware.
- SDK or library retry configuration (HTTP clients, message consumers, database drivers, job frameworks).
- Circuit breakers, bulkheads, and fallback paths attached to retry flows.
- Background jobs, event consumers, and scheduled tasks that can re-queue or re-execute work.
- Timeout, deadline, and cancellation paths that interact with retry decisions.
- Observability hooks around retry attempts, backoff delays, and final outcomes.

## Core Checks

### 1. Infinite Loop Prevention
- Confirm there is an explicit maximum retry count, maximum elapsed time, or both on every retry flow.
- Flag unbounded `while (true)`, recursive retry calls, or retry loops driven only by exception type with no escape condition.
- Flag re-queue patterns in job frameworks or message consumers that re-enqueue without a delivery-attempt counter or dead-letter policy.
- Confirm that a depleted retry budget results in a definitive failure path, not a silent re-start of the same loop.
- Check that retry configuration is not overridden downstream in a way that silently removes the cap.

### 2. Backoff and Jitter Quality
- Require bounded exponential backoff — flag constant-delay or zero-delay retries between attempts.
- Prefer jitter (randomized delay offset) to prevent coordinated retry spikes when multiple instances fail simultaneously.
- Require an upper cap on the per-attempt delay so backoff does not grow indefinitely in long retry sequences.
- Check that `Retry-After` and equivalent back-pressure signals from the target system are respected and override the computed delay.
- Flag busy-wait patterns where the code spins or polls at high frequency inside the backoff window.

### 3. Resource Amplification Risk
- Count the effective maximum number of outbound calls a single original request can produce: `(1 + max_retries)` per layer, multiplied across nested layers.
- Flag nested retry policies at multiple layers (caller, client, driver, SDK) that compound request multiplication without a cross-layer budget.
- Flag retry over a fan-out — retrying an operation that itself triggers multiple downstream calls amplifies load proportionally.
- Check that each retry attempt does not allocate fresh heavyweight resources (connections, threads, large buffers) without releasing the previous attempt's resources first.
- Confirm that the combined retry load remains within connection-pool limits, thread-pool capacity, and downstream rate limits under worst-case concurrent failure scenarios.

### 4. Call Spike Prevention
- Assess what happens when a downstream service recovers after an outage: verify that all in-flight retries do not synchronize and flood the recovering service simultaneously.
- Jitter is the primary mitigation — confirm it is present and sufficient for the instance count and retry volume.
- Check whether a circuit breaker is present to absorb repeated failures and prevent unbounded retry accumulation before recovery.
- Flag designs where retry storms would be indistinguishable from normal traffic in the downstream service's metrics.
- Assess whether retry behavior under load-shedding or rate-limiting signals (`429`, backpressure queues) respects those signals rather than adding pressure.

### 5. Error Classification and Idempotency
- Verify retries are applied only to errors that are genuinely transient: timeouts, connect failures, `429`, `503`, `504`, transient lock failures, and similar.
- Flag retries on permanent errors: `400`, `401`, `403`, `404`, `409` (conflict), schema errors, domain validation failures, and constraint violations.
- Flag retries on non-idempotent operations (writes, state mutations) unless an idempotency key, deduplication token, or transaction-safe design is in place.
- Check that the code distinguishes client-side errors from server-side errors before deciding to retry.
- Confirm that partial-success responses (batch APIs, partial writes) do not trigger a full retry that re-processes already-committed items.

### 6. Deadline and Timeout Propagation
- Confirm that the total time spent retrying is bounded by the caller's end-to-end deadline or latency budget, not just by attempt count.
- Flag cases where retries can silently exceed the caller's timeout, causing the caller to give up while retry work continues consuming resources.
- Verify that cancellation tokens, context deadlines, or equivalent signals propagate into the retry loop and abort outstanding attempts promptly.
- Check that a cancelled or timed-out retry flow releases all in-progress resources and does not leave orphaned background work.

### 7. Circuit Breaker and Fallback
- Check whether a circuit breaker is warranted when the retry target has historically shown extended outages or instability.
- Verify the circuit breaker's open threshold, half-open probe policy, and close threshold are deliberately configured, not defaulted blindly.
- Confirm that the circuit breaker open state does not propagate as an application-level health failure unless that dependency is critical.
- Check that a meaningful fallback or degraded response is returned when the circuit is open, rather than propagating a timeout or a hard crash.
- Flag missing fallback in optional integrations where a degraded response is always preferable to a hard failure.

### 8. Observability
- Verify that each retry attempt is logged with attempt number, delay, error reason, and target identity.
- Verify that the final outcome (success after N retries, exhausted retries, circuit open) is recorded distinctly from a first-attempt failure.
- Confirm that metrics or tracing expose: retry count per operation, total retry budget consumed, backoff delay distribution, and final failure rate.
- Flag logging inside tight retry loops at high verbosity (`debug`/`info`) that can flood logs under sustained failure.
- Confirm dashboards or alerts exist for elevated retry rates, circuit-breaker open events, and retry exhaustion — these are the earliest signal of dependency instability.

## Additional Checks to Consider
- **Retry budget sharing**: when multiple callers share the same downstream dependency, check whether a shared retry budget or rate-limit token is enforced to prevent one caller from consuming all available capacity.
- **Sticky vs. stateless retry targets**: for stateful protocols (sessions, streaming, transactions), verify that retrying does not land on a different node that lacks the necessary state.
- **Queue re-delivery and dead-letter**: for message consumers and job queues, verify that maximum delivery attempts, dead-letter routing, and poison-message handling are configured so one bad message does not loop indefinitely.
- **SDK default override risk**: third-party SDKs often ship with aggressive default retry policies; verify that application-level policy takes precedence and does not stack on top of SDK retries.
- **Retry under degraded capacity**: confirm retry behavior is tested or reasoned about under high-concurrency failure scenarios, not just under single-failure unit tests.
- **Monitoring for retry storms**: ensure that a sudden increase in retry rate triggers an alert before it causes downstream saturation, not after.

## Red Flags
- Retry loop with no maximum attempt count or no maximum elapsed time.
- Immediate retry with zero delay and no jitter.
- Retries triggered by `400`, `401`, `403`, `404`, or domain validation errors.
- Non-idempotent write retried without idempotency protection.
- Nested retry policies at client, driver, and SDK layers without a cross-layer cap.
- Retrying a fan-out operation without accounting for amplified downstream call count.
- Retry logic that ignores `Retry-After` or other backpressure signals.
- Cancellation or timeout that does not propagate into the retry loop.
- Missing dead-letter or delivery-attempt limit in message or job retry flows.
- SDK default retry policy left active alongside application-level retry policy.
- No circuit breaker on a dependency with a history of extended outages.
- No logs or metrics distinguishing first-attempt failures from retried failures.
- High-verbosity logging inside a tight retry loop.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether the change is safe, warning-level, or blocking.
2. `Loop Safety Assessment`
   - Confirm whether the retry budget is bounded and the escape condition is clear.
3. `Backoff and Jitter Assessment`
   - Explain whether backoff, jitter, cap, and `Retry-After` respect are appropriate.
4. `Resource and Call Amplification Assessment`
   - Quantify the worst-case effective call multiplier and assess whether it is within safe limits.
5. `Error Classification and Idempotency Assessment`
   - Confirm whether retried error types and operation idempotency are correct.
6. `Circuit Breaker and Fallback Assessment`
   - State whether a circuit breaker is present, warranted, or missing, and whether a fallback is defined.
7. `Observability Assessment`
   - Confirm whether retry attempts, budget consumption, and final outcomes are visible.
8. `Suggestions`
   - List the smallest improvements that would materially reduce retry risk.
