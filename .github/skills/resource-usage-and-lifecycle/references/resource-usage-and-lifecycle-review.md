# Resource Usage And Lifecycle Review Guide

## CPU And Memory Questions
- Does this change increase per-request CPU cost or background CPU utilization?
- Can memory usage grow with traffic, input size, or time without a bound?
- Are large objects copied or retained longer than needed?

## Resource Lifecycle Questions
- What resources are allocated here (file, stream, socket, connection, timer, subscription)?
- Where are they released on success, failure, timeout, and cancellation?
- Can shutdown leave tasks, handles, or queues active?

## Expectations
- Hot paths avoid unnecessary repeated expensive work.
- Memory-heavy structures have explicit bounds and lifecycle.
- Disposable resources are released deterministically.
- Async work has ownership, cancellation, and completion/error handling.

## Observability Expectations
- Monitor CPU, memory, GC pause, queue depth, and open handles.
- Alert on memory growth trend, sustained high CPU, and leak-like drift.
- Validate with soak tests and high-load scenarios, not only short tests.