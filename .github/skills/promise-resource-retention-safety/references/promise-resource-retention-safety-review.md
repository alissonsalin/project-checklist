# Promise Resource Retention Safety Review Guide

## Settlement Questions
- Can this promise remain pending forever on any branch?
- What guarantees settlement when exceptions are thrown mid-flow?
- Is there a timeout/deadline when waiting on external I/O?

## Exception And Cleanup Questions
- Does cleanup run on both resolve and reject paths?
- Can thrown errors bypass release of timers, streams, locks, or buffers?
- Are partial-failure steps rolled back or cleaned consistently?

## Retention Questions
- Do closures capture large objects that outlive request/job scope?
- Are pending-task maps or dedup registries bounded and evicted?
- Are event listeners removed when promise flow ends?

## Concurrency Questions
- Is parallel async work bounded or user-input dependent?
- Can retries multiply in-flight tasks under dependency failure?
- Are cancellation and backpressure signals propagated end-to-end?

## Expectations
- Promise lifecycle is bounded: settle, timeout, or cancel.
- Exception paths are observable and always release resources.
- In-flight tracking structures have strict bounds and cleanup.
- Async failure behavior is tested and visible in telemetry.

## Useful Checks To Add
- Rejection and timeout unit tests.
- Cancellation propagation tests.
- In-flight queue cap and eviction tests.
- Soak tests for memory slope under sustained async load.
- Alerts for unhandled rejection rate and backlog growth.
