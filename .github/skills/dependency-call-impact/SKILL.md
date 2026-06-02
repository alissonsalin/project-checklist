---
name: dependency-call-impact
description: 'Review the impact of multiplied HTTP or database calls. Use when changes add loops, fan-out, batching, joins, repeated lookups, nested dependency calls, parallel requests, or any flow that can increase total external call count, latency, or saturation risk.'
argument-hint: 'Describe the changed flow, especially where HTTP or database calls may repeat or multiply.'
user-invocable: true
---

# Dependency Call Impact

Use this skill when a change may increase how many external HTTP or database calls happen in a request path, background job, or batch process.

This skill exists to catch call multiplication problems such as N+1 queries, per-item HTTP requests, nested fan-out, retry amplification, and unbounded parallelism that can turn a small code change into a large latency or capacity incident.

## What to Review
- Loops over items that perform HTTP calls, database queries, or both.
- New orchestration flows that call multiple downstream services or multiple repositories per request.
- Changes to batching, joins, eager loading, caching, prefetching, pagination, or aggregation logic.
- Parallel execution, worker fan-out, async pipelines, and concurrency changes.
- Retry layers that may multiply call count across HTTP, database, queues, or orchestration layers.
- Health checks or startup flows that now perform multiple dependency calls.

## Core Checks
1. Map the effective call count.
   - Estimate how many HTTP and database calls occur per request, per item, per page, per batch, and per retry.
   - Compare the new call count with the previous behavior.
   - Flag cases where call count grows with collection size and has no explicit bound.
2. Detect N+1 and loop-driven dependency access.
   - Flag database queries inside loops when a join, eager load, batch read, or set-based operation would avoid repetition.
   - Flag per-item HTTP calls when a bulk endpoint, cache, prefetch, or aggregation layer could reduce total requests.
   - Flag nested dependency calls where each outer result triggers another dependency fan-out.
3. Check batching and reuse opportunities.
   - Prefer batch queries, bulk APIs, request coalescing, and caching when the same dependency data is fetched repeatedly.
   - Check whether pagination or chunking strategy keeps resource use bounded.
   - Check whether repeated lookups can be memoized within a request or job scope.
4. Check concurrency and saturation risk.
   - Verify parallel calls are bounded by concurrency limits.
   - Flag naive `Task.WhenAll` or equivalent over unbounded collections.
   - Check whether parallel queries can exhaust the connection pool, increase lock contention, or exceed downstream rate limits.
   - Check whether parallel HTTP calls can overwhelm the downstream service or the local thread pool.
5. Check retry amplification.
   - Multiply the base call count by retry policy across all layers.
   - Flag flows where one user request can explode into many dependency calls under failure conditions.
   - Flag nested retries between HTTP client, repository, worker, and orchestrator layers.
6. Check latency and health impact.
   - Verify the added dependency calls fit within request or job latency budgets.
   - Check whether a slowdown in one dependency now delays unrelated work or causes health-probe failure.
   - Flag startup or readiness paths that now depend on many external calls instead of a minimal bounded check.
7. Check observability.
   - Ensure telemetry can show per-request or per-job dependency count, fan-out, latency, and saturation.
   - Ensure slow-path logging or traces reveal where call multiplication occurs.
   - Flag changes where higher call count would be invisible until production saturation.

## Suggestions to Consider
- Replace per-item database reads with set-based queries, joins, eager loading, or bulk fetches.
- Replace per-item HTTP requests with bulk endpoints, gateway aggregation, or request coalescing.
- Add request-scoped caching or memoization for repeated lookups.
- Add pagination or chunking limits so large inputs cannot trigger unbounded dependency usage.
- Bound parallelism with semaphores, worker limits, or pool-aware concurrency control.
- Move expensive repeated reads to precomputed views, caches, or materialized aggregates when freshness allows.
- Collapse nested retries so only one layer owns retry policy.
- Add backpressure when item count or dependency latency rises.
- Add sampling or tracing fields that show downstream call count per request.
- Add performance tests for large collections, slow dependencies, and partial outages.
- Add guardrails that reject or defer work when fan-out exceeds safe operational limits.
- Review whether the flow should be asynchronous or batch-oriented instead of inline on the request path.

## Red Flags
- HTTP calls or SQL queries inside an unbounded loop.
- N+1 query behavior introduced by ORM navigation or lazy loading.
- Per-item external enrichment during a user-facing request with no batching.
- Unbounded `Task.WhenAll`, fork-join, or worker fan-out over user-controlled input size.
- A single request that can trigger dozens or hundreds of retries across dependencies.
- Health checks or startup logic that call several external services or run expensive queries.
- Parallel database queries that can consume most of the pool.
- Large fan-out with no metrics showing dependency count per request.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether the change is safe, warning-level, or blocking.
2. `Call Count Assessment`
   - Explain the effective number of HTTP and database calls and whether it is acceptably bounded.
3. `Fan-Out And Saturation Assessment`
   - Explain whether batching, concurrency, retries, and capacity controls are appropriate.
4. `Latency And Health Impact`
   - Explain whether multiplied dependency calls could degrade latency or push the app toward unhealthy behavior.
5. `Suggestions`
   - List the smallest improvements that would materially reduce call amplification risk.

## Reference
- Use [dependency-call-impact-review](./references/dependency-call-impact-review.md) for a compact decision guide.