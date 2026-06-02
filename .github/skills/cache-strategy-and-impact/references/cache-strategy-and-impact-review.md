# Cache Strategy And Impact Review Guide

## Scope Questions
- Is this cache in-memory per instance, Redis, or another distributed store?
- Does this path require strict freshness or can it tolerate bounded staleness?
- What is the miss-path behavior under high traffic or cache outage?

## Key And Data Safety
- Keys should include required scope dimensions such as tenant and user where applicable.
- Key cardinality should be bounded and observable.
- Cached payload schema should be versioned when contract changes are possible.

## Freshness And Consistency
- TTL and invalidation should align with business correctness requirements.
- Critical read-after-write flows should avoid stale reads or use explicit bypass/invalidation.
- Mutable data needs a deterministic invalidation or refresh strategy.

## Outage And Saturation
- Cache outage should degrade gracefully, not overwhelm primary dependencies.
- Miss storms should be controlled with coalescing, jitter, and bounded concurrency.
- Timeouts and fallback should protect user latency budgets.

## Observability Expectations
- Track hit ratio, miss ratio, cache latency, fallback rate, stale-read rate, and eviction behavior.
- Alert on hit-ratio collapse, fallback spikes, and cache error spikes.
- Validate behavior with cold-start, outage, and high-cardinality load tests.