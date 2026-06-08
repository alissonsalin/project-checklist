---
name: queue-consumer-processing-safety
description: 'Review queue and stream consumers for per-message log flood, per-message dependency call amplification, retry/DLQ safety, ack/commit correctness, idempotency, and downstream saturation risk. Use when changes add or modify Kafka, RabbitMQ, SQS, Service Bus, Pub/Sub, or other consumer flows.'
argument-hint: 'Describe the changed consumer path and where per-message logs, external calls, database calls, retries, and commit/ack behavior may create risk.'
user-invocable: true
---

# Queue Consumer Processing Safety

Use this skill when a change adds, removes, or modifies queue or stream consumer behavior.

This skill exists to catch high-volume production risks where per-message work is safe in isolation but unsafe at throughput, replay, or failure scale.

## What to Review
- Consumer handlers for Kafka, RabbitMQ, SQS, Service Bus, Pub/Sub, or internal queue abstractions.
- Per-message logging behavior, structured fields, and payload logging.
- Per-message dependency usage: HTTP calls, database access, cache reads/writes, and filesystem or object-store operations.
- Retry, requeue, dead-letter, poison-message, and backoff behavior.
- Ack/commit sequencing, offset management, and partial-failure handling.
- Concurrency, partition assignment, prefetch/fetch size, and worker scaling.
- Telemetry for lag, retries, dead-letter rates, throughput, and processing latency.

## Core Checks
1. Validate per-message log volume and cardinality.
   - Flag steady-state `info` or `warning` logs emitted for every message in high-throughput paths.
   - Flag full payload logging or unbounded fields (raw body, stack traces, full headers) on the hot path.
   - Verify retry loops do not duplicate high-severity logs for each attempt.
2. Map effective work per message.
   - Estimate dependency calls per message in normal and worst-case (including retries and nested retries).
   - Multiply by expected throughput, replay windows, and backlog catch-up behavior.
   - Flag per-message call patterns that can saturate downstream systems.
3. Validate external HTTP calls inside consumers.
   - Ensure explicit timeout, bounded retry, and jittered backoff.
   - Ensure non-idempotent writes are not blindly retried.
   - Flag fan-out patterns where one message triggers many downstream requests without bounds.
4. Validate database access per message.
   - Flag N+1, row-by-row writes, or repeated lookups that should be batched or set-based.
   - Ensure transactions are scoped, timed out, and not held across external network calls.
   - Verify pool usage remains safe at concurrent consumer throughput.
5. Validate retry, requeue, and DLQ discipline.
   - Require explicit max attempts or max processing age.
   - Require poison-message handling that avoids infinite reprocessing loops.
   - Verify DLQ routing includes enough context for recovery and triage.
6. Validate ack/commit correctness.
   - Ensure ack/offset commit occurs only after required side effects complete successfully.
   - Flag early commit/ack that can lose messages on partial failure.
   - Flag late commit/ack that can cause excessive duplicates without idempotency protection.
7. Validate idempotency and deduplication.
   - Check for idempotency key, dedup table, or equivalent guard for at-least-once delivery.
   - Verify replay behavior is safe for writes, notifications, and external side effects.
   - Flag exactly-once assumptions that are not technically guaranteed by the current flow.
8. Validate concurrency and backpressure controls.
   - Verify partition/thread/worker concurrency is bounded.
   - Verify pause, throttle, queue depth, or deferred processing behavior under downstream stress.
   - Flag configurations where backlog recovery can overload dependencies.
9. Validate ordering and partition assumptions.
   - Confirm required ordering keys are preserved where business logic depends on sequence.
   - Flag shared mutable state updates that can race across partitions or workers.
   - Verify out-of-order and duplicate delivery are explicitly tolerated or prevented.
10. Validate observability and operations.
   - Ensure metrics/traces expose lag, handler latency, retries, DLQ rate, commit/ack failures, and downstream dependency latency.
   - Ensure alerts exist for sustained lag growth, DLQ spikes, and retry storms.
   - Ensure runbooks or operator notes define drain, replay, and rollback behavior.

## Suggestions to Consider
- Move per-message success logs to `debug` and keep `info` for aggregate periodic summaries.
- Add structured sampling for repeated failure logs to prevent flood while preserving signal.
- Batch dependency calls where possible, or split enrichment into bounded asynchronous stages.
- Add bounded worker concurrency, pool-aware limits, and downstream rate limiting.
- Add explicit retry budget (attempt and time), poison-message threshold, and DLQ routing.
- Add idempotency keys and dedup guards around externally visible side effects.
- Reorder processing so commit/ack happens after durable success criteria are met.
- Add per-message deadlines and cancel work when deadline is exceeded.
- Add separate dashboards for lag, throughput, retries, DLQ, and dependency saturation.
- Add load and replay tests that simulate backlog catch-up with degraded dependencies.
- Add data-minimization and redaction checks for logged or forwarded message fields.

## Red Flags
- Every consumed message produces `info`/`warning` logs under normal operation.
- Consumer performs one or more external HTTP calls per message with unbounded retries.
- Consumer runs one or more database queries per message in unbounded loops.
- Ack/commit is recorded before required write side effects complete.
- Poison messages can cycle forever without DLQ escape.
- Replay or backlog catch-up can overwhelm downstream APIs or database pools.
- Duplicate deliveries can create duplicate writes because idempotency is missing.
- No metrics for lag, retry volume, DLQ volume, or handler latency.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether queue consumer behavior is safe, warning-level, or blocking.
2. `Per-Message Cost And Log Assessment`
   - Explain whether per-message logging and dependency work are acceptably bounded for expected throughput.
3. `Delivery Safety Assessment`
   - Explain whether retry, DLQ, idempotency, and ack/commit behavior are safe for failure and replay.
4. `Saturation And Operations Assessment`
   - Explain whether concurrency, backpressure, and observability are sufficient for production stability.
5. `Suggestions`
   - List the smallest improvements that materially reduce queue consumer risk.

## Reference
- Use [queue-consumer-processing-safety-review](./references/queue-consumer-processing-safety-review.md) for a compact decision guide.