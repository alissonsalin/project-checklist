---
name: promise-resource-retention-safety
description: 'Review promise/async flows for unresolved promises, exception paths, and retained references that can leak memory or hold resources. Use when changes add or modify promises, async tasks, cancellation, buffering, or error paths.'
argument-hint: 'Describe the changed promise/async path where unresolved operations or exceptions may retain memory or resources.'
user-invocable: true
---

# Promise Resource Retention Safety

Use this skill when a change introduces or modifies promise-based asynchronous behavior that can retain memory or open resources during failure paths.

This skill exists to catch unresolved promises, dropped rejections, stalled awaits, and closure-retention patterns that keep buffers, handles, sockets, or large objects alive longer than intended.

## What to Review
- New or modified `Promise`/`async`/`await` flows, including task orchestration and fan-out.
- Error paths where thrown exceptions can bypass cleanup or cancellation.
- Long-lived closures capturing request context, payloads, or large objects.
- In-flight maps, dedup caches, pending task registries, and retry queues.
- Timers, subscriptions, and streaming operations coupled with promise completion.
- Cancellation and timeout behavior used to settle or abandon pending async work.

## Core Checks
1. Check promise settlement guarantees.
   - Verify promises are always resolved, rejected, or canceled in all code paths.
   - Flag branches where exceptions can skip settlement and leave pending work forever.
   - Flag unresolved deferred/promise-completer patterns without timeout or cleanup.
2. Check exception-path cleanup.
   - Verify `finally` or equivalent cleanup always runs when await chains fail.
   - Flag code where thrown/rejected errors bypass releasing buffers, streams, locks, or timers.
   - Verify cleanup for partial progress in multi-step async workflows.
3. Check rejection handling and observability.
   - Flag dropped rejections and unobserved task failures.
   - Verify top-level promise boundaries log and classify failures with correlation context.
   - Verify errors are surfaced to callers instead of hanging indefinitely.
4. Check retention and closure pressure.
   - Flag promise closures that capture large payloads or long-lived object graphs.
   - Check pending-task registries/maps for bounded size and eviction on failure.
   - Flag reference cycles or event-listener capture that can prevent GC.
5. Check cancellation and timeout discipline.
   - Verify async operations have explicit timeout/deadline/cancellation propagation.
   - Flag promises waiting on external I/O with no deadline.
   - Verify canceled tasks release resources and remove references from tracking structures.
6. Check fan-out and backpressure.
   - Flag unbounded `Promise.all`/parallel launches on user-controlled or high-volume input.
   - Verify bounded concurrency and queue limits for in-flight async work.
   - Verify retries do not multiply pending promises under dependency failure.
7. Check tests and runtime signals.
   - Verify tests cover rejection, timeout, cancellation, and cleanup behavior.
   - Verify telemetry shows in-flight promise count, queue depth, timeout rate, and unhandled rejection rate.
   - Flag changes that update only success-path tests for async flows.

## Suggestions To Consider
- Add `finally` cleanup to all promise chains that allocate resources.
- Add bounded concurrency helpers instead of raw unbounded `Promise.all`.
- Add timeout wrappers with cancellation propagation for external async calls.
- Add eviction and TTL for in-flight registries and dedup maps.
- Add explicit rejection handlers for fire-and-forget or detached tasks.
- Add abort signal support for nested async calls.
- Add caps on per-tenant or per-request pending promise counts.
- Add alerts for unhandled rejections and rising in-flight backlog.
- Add memory snapshots/soak tests for long-running async workloads.
- Add guardrails preventing large object capture in long-lived closures.
- Add jittered retry with max-attempt limits to avoid pending-task storms.
- Add dead-letter or quarantine handling where async jobs repeatedly fail before cleanup.

## Red Flags
- Promise can remain pending forever on an exception or branch.
- Fire-and-forget task has no rejection handling or ownership.
- In-flight map/set grows without bound after failures/timeouts.
- `Promise.all` on large/unbounded input causes memory spikes.
- Missing timeout/cancellation for external await points.
- Cleanup logic runs only on success path, not on rejection.
- Event listeners/timers created during async flow are never removed.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether promise/resource retention risk is safe, warning-level, or blocking.
2. `Promise Lifecycle Assessment`
   - Explain settlement, rejection handling, and async boundary safety.
3. `Retention And Cleanup Assessment`
   - Explain memory/resource retention risk across success, failure, and cancellation paths.
4. `Concurrency And Backpressure Assessment`
   - Explain fan-out, pending-work bounds, and retry amplification risk.
5. `Suggestions`
   - List the smallest improvements that materially reduce promise-related leak risk.

## Reference
- Use [promise-resource-retention-safety-review](./references/promise-resource-retention-safety-review.md) for a compact decision guide.
