# Dependency Call Impact Review Guide

## Primary Questions
- How many HTTP and database calls can one request, message, or batch trigger in the normal case?
- How many can it trigger in the worst case, including retries?
- Does call count grow with input size, page size, or result size?
- Are any calls executed inside loops, lazy-loading paths, or nested fan-out branches?

## Efficiency Expectations
- Prefer set-based database access over row-by-row access.
- Prefer bulk or aggregated HTTP endpoints over per-item enrichment calls.
- Cache repeated reads when the same data is fetched several times in one flow.
- Keep startup and health-check dependency usage minimal and bounded.

## Saturation Expectations
- Bound concurrency.
- Respect connection-pool size, downstream rate limits, and worker capacity.
- Avoid layered retries that multiply fan-out.
- Ensure large inputs cannot create unbounded dependency pressure.

## Useful Questions
- What happens with 10x more items in the loop?
- What happens if the dependency is slow and every call retries?
- Can one request monopolize the connection pool or outbound client slots?
- Can repeated lookups be batched, joined, prefetched, or cached?
- Is the added fan-out visible in traces, metrics, or logs?