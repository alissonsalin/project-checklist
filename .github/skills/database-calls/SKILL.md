---
name: database-calls
description: 'Review database calls for transient-failure retries, backoff, transaction safety, timeouts, connection-pool impact, and application health behavior. Use when changes add or modify queries, ORM access, repositories, migrations, transaction flow, or database health checks.'
argument-hint: 'Describe the changed database access path or the diff scope to review.'
user-invocable: true
---

# Database Calls

Use this skill when a change adds, removes, or modifies any database interaction.

This skill exists to prevent fragile database access patterns from causing retry storms, lock amplification, transaction duplication, pool exhaustion, or avoidable application health failures.

## What to Review
- New or modified queries, ORM calls, repositories, gateways, unit-of-work code, or data access helpers.
- Retry logic, reconnect behavior, failover handling, and transaction orchestration.
- Connection-pool configuration, concurrency controls, and queueing around database access.
- Startup checks, readiness checks, liveness checks, workers, and background jobs that depend on database availability.
- Telemetry changes for queries, retries, lock contention, and connection-pool health.

## Core Checks
1. Identify the data access path.
   - Find where the database call is created and executed.
   - Confirm whether the change affects a single query path or a shared repository/client used broadly.
2. Verify retries exist only where safe.
   - Accept retries for transient failures such as dropped connections, deadlocks, serialization conflicts, lock timeouts, or short failover events.
   - Flag retries for deterministic query errors, schema mismatches, constraint violations, syntax errors, or permission failures.
   - Flag retries that rerun non-idempotent writes without a transaction-safe design, deduplication, or idempotent command handling.
3. Verify backoff and reconnect quality.
   - Require bounded backoff instead of immediate reconnect or tight-loop query retries.
   - Prefer jitter when multiple workers or instances can retry together.
   - Require a retry cap, reconnect cap, or total time budget.
   - Flag nested retries between ORM, driver, and caller layers that multiply load.
4. Verify transaction and timeout behavior.
   - Ensure queries and transactions have explicit timeout or cancellation behavior.
   - Ensure retries do not cross transaction boundaries in a way that duplicates writes or breaks consistency.
   - Flag long-running transactions that hold locks while waiting on external work.
   - Check that rollback or compensation behavior is defined for partial failure paths.
5. Protect pool health and resource usage.
   - Check whether connection-pool settings, concurrency, and queue depth can absorb degraded database performance.
   - Flag changes that can exhaust the pool, create thundering herds, or block request threads.
   - Prefer backpressure, queue limits, and workload isolation for expensive or bursty query paths.
6. Protect application health.
   - Check whether database failures incorrectly fail readiness or liveness.
   - If the database is critical, require the unhealthy behavior to be explicit and justified.
   - If parts of the application can degrade gracefully, prefer reduced functionality over restart loops.
   - Flag startup paths that block indefinitely waiting for the database.
7. Check observability.
   - Ensure logs distinguish transient retryable failures from permanent data errors.
   - Ensure metrics or tracing expose query latency, retry count, timeout rate, deadlocks, and pool saturation.
   - Flag changes that hide lock contention, slow queries, or failover instability.

## Suggestions to Consider
- Add deadlock-aware retry handling for known retryable transaction failures.
- Add bounded exponential backoff with jitter for reconnects and retryable transactions.
- Add idempotent command handling or deduplication for retried writes.
- Keep transactions narrow and avoid external network calls while a transaction is open.
- Add statement timeouts, query cancellation, or request deadlines.
- Add pool limits, queue limits, and backpressure to prevent thread or worker starvation.
- Separate readiness from liveness so a transient database incident does not cause restart storms.
- Add read-only or cached degraded behavior when full write capability is unavailable.
- Add tests for deadlocks, transient disconnects, failover events, and pool exhaustion.
- Add dashboards or alerts for slow queries, deadlocks, timeout spikes, and pool saturation.
- Centralize retry and timeout policy in shared data-access infrastructure so repositories do not drift.

## Red Flags
- Infinite reconnect or retry loops.
- Immediate retry on deadlock or disconnect with no backoff.
- Retrying unique-constraint violations, syntax errors, or authorization failures.
- Retrying writes across ambiguous commit boundaries without idempotency protection.
- Long transactions that include HTTP calls, message publishing, or other external waits.
- Missing timeout on a query or transaction.
- Connection-pool exhaustion that can block the whole process.
- Health probes tied directly to optional read models or non-critical database features.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether the change is safe, warning-level, or blocking.
2. `Retry Assessment`
   - Explain whether retry behavior is present, correctly scoped, and safe for the affected query or transaction pattern.
3. `Backoff And Pool Assessment`
   - Explain whether backoff, reconnect behavior, and pool protection are appropriate.
4. `Consistency And Health Impact`
   - Explain whether transaction safety and application health behavior are acceptable.
5. `Suggestions`
   - List the smallest improvements that would materially reduce database integration risk.

## Reference
- Use [database-call-review](./references/database-call-review.md) for a compact decision guide.