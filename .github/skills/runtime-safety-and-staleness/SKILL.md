---
name: runtime-safety-and-staleness
description: 'Review changes for runtime exceptions, invalid assumptions, race conditions, and stale-data behavior. Use when changes add or modify nullable values, collection access, parsing, caching, concurrency, replica reads, version checks, or stateful business decisions.'
argument-hint: 'Describe the changed code path where runtime safety or stale-data risk may have increased.'
user-invocable: true
---

# Runtime Safety And Stale Data

Use this skill when a change may introduce runtime exceptions or make business logic rely on outdated or inconsistent data.

This skill exists to catch failures such as null dereferences, invalid collection access, unsafe parsing, race conditions, stale cache reads, lost updates, and read-model lag that may not appear in the happy path but can fail in production.

## What to Review
- New or modified code that reads optional values, nested objects, collections, configuration, feature flags, or environment variables.
- Parsing, mapping, deserialization, casting, and schema-dependent logic.
- Cache reads and writes, replica reads, snapshots, in-memory state, and read models.
- Concurrent flows, async orchestration, background refresh, and object lifecycle changes.
- Business decisions that depend on freshness, ordering, or the latest persisted state.

## Core Checks
1. Check null and missing-value safety.
   - Flag dereferences, property access, or method calls that assume values are always present.
   - Check whether optional external fields, config values, or deserialized properties can be missing.
   - Prefer explicit guards, defaults, validation, or fail-fast behavior over silent assumptions.
2. Check collection and type safety.
   - Flag unchecked index access, empty-sequence assumptions, invalid casts, and unchecked enum or state values.
   - Check whether parsing can fail for malformed, partial, or future-version input.
   - Check whether default branches handle unknown values safely.
3. Check lifecycle and concurrency safety.
   - Flag reads from partially initialized objects or state mutated across async boundaries.
   - Flag race conditions around cache fill, lazy initialization, singleton mutation, and shared in-memory state.
   - Check for use-after-dispose, cancellation timing issues, and background refresh overwriting newer state.
4. Check exception boundaries.
   - Identify where runtime exceptions can occur and whether they are handled at the right boundary.
   - Check whether errors from mappers, serializers, template rendering, or feature-flag evaluation can crash the request or worker.
   - Prefer deliberate error translation and diagnostics over broad catch-and-ignore behavior.
5. Check stale-data tolerance.
   - Identify whether the code reads from cache, replica, snapshot, or eventually consistent read models.
   - Check whether the operation requires fresh data, monotonic reads, or read-after-write guarantees.
   - Flag decisions that use potentially stale data for authorization, money movement, inventory, or irreversible side effects.
6. Check consistency and lost-update protection.
   - Verify optimistic concurrency, version tokens, compare-and-set logic, or invalidation paths where concurrent writes matter.
   - Flag flows where two writers can overwrite each other without detection.
   - Check whether retries or replays can apply stale state transitions twice.
7. Check observability and tests.
   - Ensure logs, metrics, or tracing expose recurring runtime exceptions and stale-data fallbacks.
   - Prefer tests for null input, malformed payloads, cache lag, replica lag, concurrent updates, and out-of-order events.
   - Flag changes where stale-data behavior or runtime edge cases would be invisible until production failure.

## Suggestions To Consider
- Add explicit null and existence guards at trust boundaries.
- Add input validation before mapping, parsing, or state transition logic.
- Replace unchecked index access with safe lookup patterns.
- Add default handling for unknown enum values or future schema versions.
- Add defensive checks around config and feature-flag reads.
- Add optimistic concurrency tokens, row versions, or compare-and-set semantics for update paths.
- Add cache invalidation, TTL review, or freshness checks where stale reads can affect correctness.
- Prefer primary reads or explicit freshness requirements for critical decisions.
- Add idempotency and replay protection when stale messages or retries can reapply old state.
- Add tests for nulls, malformed input, concurrent mutation, cache lag, and replica lag.
- Add alerts or dashboards for exception rate, stale cache hit rate, and concurrency conflicts.
- Narrow broad exception handlers so real defects are visible and actionable.

## Red Flags
- Possible null dereference on external or optional data.
- Unchecked `First`, index, or key access on data that may be missing.
- Parsing or cast assumptions with no fallback for malformed input.
- Shared mutable state accessed across async flows without synchronization.
- Cache or replica reads used for critical business decisions with no freshness guarantee.
- Missing version check on concurrent update paths.
- Read-after-write logic implemented on eventually consistent data with no compensation.
- Broad exception swallowing that hides runtime defects.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether the change is safe, warning-level, or blocking.
2. `Runtime Safety Assessment`
   - Explain whether null, parsing, type, lifecycle, and exception risks are adequately controlled.
3. `Freshness And Consistency Assessment`
   - Explain whether stale-data tolerance, versioning, and update safety are acceptable.
4. `Edge-Case Coverage`
   - Explain whether tests, guards, and telemetry cover the failure modes.
5. `Suggestions`
   - List the smallest improvements that would materially reduce runtime or stale-data risk.

## Reference
- Use [runtime-safety-and-staleness-review](./references/runtime-safety-and-staleness-review.md) for a compact decision guide.