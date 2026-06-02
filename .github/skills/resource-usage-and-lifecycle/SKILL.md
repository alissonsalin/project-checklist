---
name: resource-usage-and-lifecycle
description: 'Review CPU usage, memory usage, and resource lifecycle safety. Use when changes add or modify loops, batching, buffering, concurrency, streams, sockets, files, timers, subscriptions, background jobs, or other paths that allocate and release resources.'
argument-hint: 'Describe the changed path where CPU, memory, or resource release behavior may have changed.'
user-invocable: true
---

# Resource Usage And Lifecycle

Use this skill when a change may alter CPU usage, memory usage, or resource release behavior.

This skill exists to catch performance and stability issues such as CPU hotspots, memory growth, GC pressure, unbounded buffers, leaked handles, and unreleased resources that degrade user experience and service reliability.

## What to Review
- New or modified loops, data transformations, and per-request/per-item processing.
- Buffering, batching, queueing, and in-memory aggregation behavior.
- Files, streams, sockets, database connections, HTTP clients, timers, event handlers, and subscriptions.
- Async and background worker code that allocates long-lived objects or external resources.
- Cancellation, timeout, retry, and shutdown paths that should stop work and release resources.
- Telemetry and tests related to performance, memory, and leak detection.

## Core Checks
1. Check CPU cost and hot paths.
   - Flag nested loops, repeated expensive calls, and avoidable per-item serialization/parsing in hot paths.
   - Flag polling or busy-wait patterns that consume CPU continuously.
   - Verify concurrency level does not oversubscribe CPU and increase context-switch overhead.
2. Check memory growth and object lifetime.
   - Flag unbounded collections, caches, queues, and buffers.
   - Flag retaining references longer than needed, especially in static/singleton structures.
   - Check whether large objects are copied repeatedly instead of reused/streamed.
3. Check resource allocation and release.
   - Verify streams, files, sockets, locks, timers, subscriptions, and handles are disposed/unsubscribed deterministically.
   - Flag missing `finally`/defer/using-equivalent patterns around allocated resources.
   - Flag resources created per-request that should be reused safely at a higher scope.
4. Check async lifecycle safety.
   - Flag fire-and-forget tasks with no cancellation, error handling, or lifecycle ownership.
   - Check whether background tasks can accumulate and leak memory or handles.
   - Verify cancellation tokens/signals propagate to child operations.
5. Check shutdown and failure paths.
   - Verify timeouts and cancellation stop work and release resources.
   - Verify partial failures do not leave open resources, orphan tasks, or blocked queues.
   - Verify graceful shutdown drains or abandons work safely without leaks.
6. Check user and service impact explicitly.
   - User impact: assess latency spikes, timeouts, and degraded responsiveness.
   - Service impact: assess CPU saturation, memory pressure, GC pause amplification, restart frequency, and infra cost.
   - Flag tradeoffs where lower latency increases unsafe CPU or memory growth.
7. Check observability and test coverage.
   - Ensure telemetry includes CPU usage, memory usage, heap growth, GC pressure, queue depth, and active handle counts.
   - Ensure traces/logs can correlate latency regressions with resource pressure.
   - Prefer tests/load tests for long-running scenarios to reveal leaks and resource drift.

## Suggestions To Consider
- Add bounds to buffers, queues, and in-memory aggregations.
- Replace full materialization with streaming when possible.
- Reuse heavy clients/resources safely instead of creating them per request.
- Add deterministic disposal patterns for all allocated resources.
- Add cancellation propagation to all nested async operations.
- Add backpressure when producers can outrun consumers.
- Add circuit-breakers or admission control during CPU/memory pressure.
- Tune batch sizes to balance throughput and memory footprint.
- Add periodic leak checks in soak tests.
- Add dashboards for CPU, RSS/heap, GC pause time, queue depth, and open handles.
- Add alerts for memory growth slope, CPU saturation, and abnormal restart frequency.
- Document resource ownership and expected lifetime for long-lived objects.

## Red Flags
- Infinite or near-infinite loops, busy-wait loops, or tight polling.
- Unbounded queue or list growth in request or background paths.
- Creating disposable resources without guaranteed release.
- Fire-and-forget tasks with no ownership or cancellation.
- Per-request client creation causing connection churn and extra CPU.
- Large object allocations in hot loops causing frequent GC pressure.
- Timers or event subscriptions that are never removed.
- Shutdown path that exits without releasing open resources.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether the change is safe, warning-level, or blocking.
2. `CPU And Memory Assessment`
   - Explain whether CPU and memory usage are acceptably bounded for the changed path.
3. `Resource Lifecycle Assessment`
   - Explain whether allocated resources are reliably released in normal, failure, and shutdown paths.
4. `User And Service Impact`
   - Explain expected impact on user latency and service stability/cost.
5. `Suggestions`
   - List the smallest improvements that would materially reduce resource risk.

## Reference
- Use [resource-usage-and-lifecycle-review](./references/resource-usage-and-lifecycle-review.md) for a compact decision guide.