# Exception Handling Safety Review Guide

## Boundary Questions
- If this operation throws, where is it caught and how is it translated?
- Can the exception escape a request/worker boundary and terminate execution?
- Does the catch behavior preserve stack/context for diagnosis?

## Catch-Block Questions
- Is the catch typed and intentional, or too broad?
- Is the exception swallowed without logging, metric, or compensating action?
- Is rethrow done in a way that preserves original context?

## Async Questions
- Can exceptions in background or fire-and-forget work go unobserved?
- Are cancellation and timeout failures propagated consistently?
- Is there a clear error channel for asynchronous failure paths?

## Expectations
- Critical boundaries prevent unhandled runtime exceptions from crashing core flows.
- Catch blocks are explicit, actionable, and observable.
- Failure translation is consistent and safe for callers.
- Runtime failure paths are tested and monitored.

## Useful Checks To Add
- Boundary tests for unhandled-exception prevention.
- Catch-block behavior tests for mapping and fallback correctness.
- Async fault-propagation tests.
- Dependency-failure translation tests.
- Alert checks for exception-rate spikes.
