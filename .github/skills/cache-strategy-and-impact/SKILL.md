---
name: cache-strategy-and-impact
description: 'Review cache design and impact for in-memory, Redis, and distributed cache usage. Use when changes add or modify cache keys, TTL, invalidation, serialization, fallback behavior, cache-aside/write-through flows, or cache-dependent business logic.'
argument-hint: 'Describe the changed cache path and expected user/service impact.'
user-invocable: true
---

# Cache Strategy And Impact

Use this skill when a change introduces or modifies cache behavior in application memory, Redis, or other distributed cache systems.

This skill exists to catch cache risks that affect both user experience and service reliability, such as stale decisions, key collisions, invalidation bugs, thundering herds, cache outage blast radius, and hidden cost amplification.

## What to Review
- Cache-aside, read-through, write-through, write-behind, and refresh patterns.
- In-memory caches inside service instances and cross-instance distributed caches.
- Key structure, tenant scoping, versioning, namespaces, and eviction policy assumptions.
- TTL, sliding expiration, invalidation triggers, and manual purge behavior.
- Serialization and schema compatibility for cached payloads.
- Fallback behavior when cache is unavailable, slow, or inconsistent.
- Telemetry and alerting around cache effectiveness and failure modes.

## Core Checks
1. Check key design and data boundaries.
   - Verify keys include required dimensions such as tenant, region, locale, user scope, and version.
   - Flag key collisions, unbounded key cardinality, or missing namespace strategy.
   - Flag cache entries that can mix data across users or tenants.
2. Check TTL and freshness strategy.
   - Verify TTL aligns with business freshness requirements.
   - Flag no-expiration entries without strong invalidation strategy.
   - Flag overly short TTL that causes churn and backend amplification.
   - Check whether stale reads are acceptable for the specific operation.
3. Check invalidation and update consistency.
   - Verify updates, deletes, and background jobs invalidate or refresh affected keys.
   - Check read-after-write expectations and whether users can observe stale state.
   - Flag missing versioning or compare-and-set logic where concurrent updates matter.
4. Check cache failure and miss-path impact.
   - Verify behavior when cache is down, partially unavailable, or timing out.
   - Flag fallback paths that overload primary dependencies on miss or outage.
   - Check for thundering herd protection, request coalescing, single-flight, or jittered refresh.
5. Check topology-specific risks.
   - In-memory cache: flag per-instance inconsistency that breaks cross-instance expectations.
   - Redis/distributed cache: check network timeout, circuit-breaker, serialization, and cluster failover behavior.
   - Check whether cache operations can block request threads or saturate connection pools.
6. Check user and service impact explicitly.
   - User impact: validate correctness, freshness, perceived latency, and consistency across repeated reads.
   - Service impact: validate backend load reduction, dependency pressure, cache cost, and saturation behavior.
   - Flag changes where cache improves latency but increases stale-data risk beyond acceptable bounds.
7. Check observability and tests.
   - Ensure metrics include hit ratio, miss ratio, p95/p99 cache latency, stale-read rate, and eviction rate.
   - Ensure traces/logs can distinguish cache hit, miss, fallback, and refresh paths.
   - Prefer tests for cold-start storms, invalidation races, cache outage, and stale-read edge cases.

## Suggestions To Consider
- Add key versioning to support schema changes without serving incompatible payloads.
- Add tenant-safe key prefixes and scoped namespaces.
- Add jitter to TTL or background refresh to avoid synchronized expirations.
- Add single-flight request coalescing on cache miss to prevent stampedes.
- Add stale-while-revalidate for read-heavy paths where bounded staleness is acceptable.
- Add explicit read-after-write bypass or targeted invalidation for user-critical updates.
- Add graceful degradation when cache is down, with strict timeout budgets.
- Add cache warm-up for known hot keys after deployment or failover.
- Add size and cardinality guardrails to avoid unbounded memory growth.
- Add dashboards for hit ratio, miss amplification, fallback rate, and cache error rate.
- Add alerts for sudden hit-ratio drops, eviction spikes, or fallback latency spikes.
- Add load tests for cold cache, partial cache outage, and high-cardinality key patterns.

## Red Flags
- Cache keys missing tenant/user scope for sensitive data.
- No invalidation path for mutable data.
- TTL that conflicts with business correctness requirements.
- Cache miss path that causes backend fan-out or lock contention.
- In-memory cache used where cross-instance consistency is required.
- Redis timeout settings that can block request processing.
- Serving stale security, authorization, pricing, or inventory decisions.
- No telemetry to detect cache regressions or outage fallback behavior.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether the change is safe, warning-level, or blocking.
2. `Cache Design Assessment`
   - Explain whether key design, TTL, invalidation, and topology choices are sound.
3. `User Impact Assessment`
   - Explain correctness, freshness, and latency impact for end users.
4. `Service Impact Assessment`
   - Explain load, dependency pressure, resilience, and cost impact on the service.
5. `Suggestions`
   - List the smallest improvements that would materially reduce cache risk.

## Reference
- Use [cache-strategy-and-impact-review](./references/cache-strategy-and-impact-review.md) for a compact decision guide.