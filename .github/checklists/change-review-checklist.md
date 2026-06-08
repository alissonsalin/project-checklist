# Change Review Checklist

Use this file as the source of truth for the review agent in `.github/agents/change-checklist-reviewer.agent.md`.

## How to Maintain
- Replace each `TODO` item with a concrete review rule.
- Keep items short, testable, and applicable to changed files.
- Group rules by concern so the review output can map findings back to a checklist section.
- Create one skill per checklist concern under `.github/skills/` when the review needs deeper decision guidance.

## Baseline
- External HTTP calls must be reviewed with the `external-http-calls` skill when a change adds or modifies outbound HTTP communication.
- Database calls must be reviewed with the `database-calls` skill when a change adds or modifies database access, retry behavior, transaction handling, or health-check behavior.
- External dependency call impact must be reviewed with the `dependency-call-impact` skill when a change increases the number, frequency, nesting, or fan-out of HTTP or database calls.
- Accidental commented-out code and committed-change impact must be reviewed with the `comment-and-impact-validation` skill when a change may leave disabled code in comments, or alters behavior that may affect other modules, callers, or operations.
- Cross-area change impact must be reviewed with the `change-impact-validation` skill when a change can affect behavior in other parts of the codebase beyond the edited files.
- Flags and environment variables must be reviewed with the `flag-and-env-validation` skill when a change adds, removes, renames, or changes config flags, feature flags, or environment-variable reads.
- Scalability must be reviewed with the `scalability-validation` skill when a change can alter capacity limits, hot-path cost, partitioning behavior, workload amplification, or system behavior under higher traffic, larger datasets, or larger batch sizes.
- Runtime safety and stale-data risk must be reviewed with the `runtime-safety-and-staleness` skill when a change can introduce runtime exceptions, invalid assumptions, cache inconsistency, or outdated reads.
- Cache strategy and cache impact must be reviewed with the `cache-strategy-and-impact` skill when a change adds or modifies in-memory cache, Redis, distributed cache access, invalidation behavior, or cache-dependent business logic.
- Resource usage and lifecycle safety must be reviewed with the `resource-usage-and-lifecycle` skill when a change can alter CPU usage, memory usage, or how resources are allocated and released.
- Logging quality and signal-to-noise must be reviewed with the `logging-signal-and-severity` skill when a change adds or modifies logging, tracing context, log levels, or alert-relevant events.
- Retry mechanism safety must be reviewed with the `retry-mechanism` skill when a change adds or modifies retry loops, resilience policies, backoff configuration, circuit breakers, re-queue behavior, or any flow that can repeat a failed operation.
- Queue consumer processing safety must be reviewed with the `queue-consumer-processing-safety` skill when a change adds or modifies Kafka, RabbitMQ, SQS, Service Bus, Pub/Sub, or other queue/stream consumers, especially per-message logging, external API calls, or database calls.

## External HTTP Calls
- Retries are present only for transient failures such as timeouts, connection failures, `429`, or `5xx` responses.
- Retry policy uses bounded exponential backoff with jitter and an upper limit.
- Retry behavior respects idempotency and does not blindly retry unsafe write operations.
- Timeout and cancellation behavior is explicit so outbound calls cannot hang indefinitely.
- Dependency failure does not push the whole application into an unhealthy state unless that dependency is explicitly critical.
- Health checks, startup flow, and degraded-mode behavior are defined for dependency outages.
- Logging, metrics, or tracing make retry storms and downstream instability visible.

## Database Calls
- Retries are present only for transient database failures such as connection drops, deadlocks, lock timeouts, or transient failover events.
- Retry policy uses bounded backoff and does not create rapid reconnect or query retry loops.
- Retry behavior respects transaction boundaries, write safety, and idempotency.
- Queries and transactions have explicit timeout, cancellation, and scope limits.
- Connection pool, concurrency, and backpressure settings avoid exhausting application or database resources.
- Database degradation does not move the whole application into an unhealthy state unless the database is explicitly critical for serving traffic.
- Health checks, startup flow, fallback behavior, and telemetry make database instability visible without causing unnecessary restart loops.

## Dependency Call Impact
- Added or modified flows do not create unbounded fan-out, N+1 query patterns, or repeated dependency calls inside loops without justification.
- The total number of HTTP and database calls per request, job, or batch remains bounded and acceptable for the expected load.
- Repeated calls are batched, cached, prefetched, joined, or otherwise reduced when the same data can be fetched more efficiently.
- Parallelism is deliberate and bounded so concurrent dependency calls do not amplify latency, rate-limit pressure, lock contention, or pool exhaustion.
- Combined retry behavior across layers does not multiply the effective number of dependency calls beyond safe limits.
- Failure, slowdown, or saturation of one dependency does not cascade into broad application slowness or unhealthy state without explicit justification.
- Telemetry makes call count, fan-out, latency amplification, and saturation visible at request or job scope.

## Change Impact Validation
- Public contract changes (method signatures, DTO/schema fields, event payloads, config keys, flags, CLI arguments) are identified and all known consumers are updated or explicitly marked for follow-up.
- Interface, abstract type, and shared utility changes are checked for downstream compile-time and runtime break risk.
- Behavioral changes (defaults, ordering, filtering, validation, error handling, retries, timeouts) are reviewed for regression impact in calling flows.
- Side effects in shared components (caching, logging, auth, serialization, concurrency, transaction boundaries) are checked across impacted call paths.
- Data model, migration, and compatibility changes include read/write compatibility checks for old and new producers/consumers during rollout.
- Feature-flag and configuration changes define safe defaults, fallback behavior, and rollback expectations for unaffected code paths.
- Impacted test coverage is updated for both the changed area and at least one representative downstream integration path.
- Risk ownership is clear: unresolved cross-area impacts are tracked with explicit follow-up action before merge.

## Comment And Impact Validation
- Commented-out executable code is not left in final commits unless explicitly justified as a temporary, tracked mitigation.
- Lines that look like disabled code in comments are reviewed to distinguish documentation/examples from accidentally disabled runtime behavior.
- Temporary commented-out code includes owner, issue reference, and planned cleanup criteria when retention is unavoidable.
- Non-obvious business logic, guard conditions, compensating behavior, and failure-path decisions include concise comments that explain intent and safety assumptions.
- Temporary mitigations, hotfix branches, and unusual workarounds are documented with removal criteria or follow-up tracking references.
- Behavioral changes introduced in committed code are checked for caller, downstream, and operator impact beyond the edited file.
- Public/shared contract changes include explicit impact notes for known consumers and rollout compatibility expectations.
- Risky code paths include evidence of impact validation such as targeted tests, compatibility checks, or explicit follow-up owner/action.
- Removed comments are reviewed to ensure readability and intent remain clear from surrounding code and naming alone.
- Changes that are intentionally self-documenting are still validated for downstream impact when behavior, data shape, or side effects changed.

## Flags And Environment Variables
- New, renamed, or removed flags and environment variables are identified and the required deployment/configuration updates are explicit.
- Behavior is safe when a value is missing, empty, malformed, or not yet set in one or more environments.
- Required settings fail fast with clear validation instead of crashing later or silently using unsafe behavior.
- Optional settings have explicit defaults and those defaults are safe for correctness, security, cost, and availability.
- Parsing of booleans, enums, numbers, durations, URLs, and structured values handles invalid input deliberately.
- Rollout and rollback remain compatible when flag names or accepted values change across mixed-version deployments.
- Shared settings used by multiple services, jobs, or controllers are reviewed for coordinated rollout and consistent behavior.
- Tests, logs, metrics, or health signals make missing or invalid configuration visible before broad production impact.

## Scalability Validation
- Added or modified paths remain acceptably bounded as request rate, tenant count, dataset size, queue depth, or batch size increases.
- Hot-path CPU, memory, locking, and serialization costs are proportional and do not create step-function regressions at expected scale.
- Partitioning, sharding, key distribution, and work allocation avoid hot spots, skew, and single-node bottlenecks.
- Concurrency, batching, and worker scaling are deliberate and bounded so throughput gains do not cause pool exhaustion, rate-limit pressure, or unstable tail latency.
- Storage, network, and downstream dependency usage remain within expected capacity envelopes under peak and recovery scenarios.
- Load shedding, backpressure, queue limits, and degraded-mode behavior are defined where overload is plausible.
- Telemetry, tests, or capacity evidence make saturation, tail latency, backlog growth, and scaling bottlenecks visible before broad production impact.
- User impact (latency, timeouts, correctness under load) and service impact (saturation, recovery time, cost) are explicitly evaluated.

## Runtime Safety And Stale Data
- Added or modified code defends against null or missing values before dereference, access, or transformation.
- Collection, index, parsing, cast, and state-transition assumptions are explicit and safe for invalid or unexpected input.
- Async and concurrent flows do not introduce race conditions, use-after-dispose errors, or partial-initialization reads.
- Exceptions from external inputs, deserialization, feature flags, configuration, or schema drift are handled deliberately.
- Cache, replica, snapshot, or in-memory state usage has an acceptable freshness model for the business operation.
- Read-after-write, optimistic concurrency, version checks, and invalidation paths prevent stale decisions or lost updates.
- Telemetry, tests, or guards make runtime failures and stale-data behavior visible before broad production impact.

## Cache Strategy And Impact
- Cache entries have clear ownership, key design, TTL policy, and invalidation behavior.
- Cache reads and writes are safe for in-memory, Redis, or distributed topologies, including serialization and compatibility concerns.
- Cache misses, evictions, or backend cache outages do not cause thundering herds, retry storms, or total service degradation.
- Cache freshness is appropriate for the business decision and does not allow harmful stale-data outcomes.
- Read-after-write expectations are explicit and supported by update, invalidation, or versioning strategy.
- Security and tenancy boundaries are enforced in cache keys, payloads, and access patterns.
- Telemetry exposes hit ratio, miss ratio, latency, stale reads, eviction behavior, and cache-fallback performance impact.
- User impact (correctness, perceived latency, consistency) and service impact (load, cost, saturation) are explicitly considered.

## Resource Usage And Lifecycle
- CPU-intensive operations are bounded and avoid unintentional hot loops, unnecessary polling, and expensive per-item work.
- Memory usage is bounded, avoids unbounded growth, and does not retain data longer than needed.
- Allocated resources such as streams, sockets, files, connections, timers, and subscriptions are released reliably after use.
- Async and background flows do not leak tasks, buffers, handles, or event listeners over time.
- Caching, batching, and buffering choices are sized with clear limits to prevent memory pressure and GC churn.
- Graceful cancellation, timeout, and shutdown paths release resources and stop work cleanly.
- Telemetry makes CPU saturation, memory growth, GC pressure, and resource-leak symptoms visible before user impact.
- User impact (latency spikes, timeouts, degraded experience) and service impact (instability, restarts, cost) are explicitly evaluated.

## Retry Mechanism
- Retry loops have an explicit maximum attempt count, maximum elapsed time, or both — infinite retry loops are not present.
- Backoff uses bounded exponential delay with jitter; constant-delay and zero-delay retries are not used.
- The per-attempt backoff delay has an upper cap, and `Retry-After` or equivalent back-pressure signals are respected.
- Retries are applied only to genuinely transient errors such as timeouts, connect failures, `429`, and `5xx`; permanent errors (`400`, `401`, `403`, `404`, constraint violations) are not retried.
- Non-idempotent write operations are not retried without an idempotency key, deduplication token, or transaction-safe design.
- Nested retry policies across caller, client, driver, and SDK layers are identified and the combined worst-case call multiplier is within safe limits.
- Retrying a fan-out operation accounts for the amplified downstream call count produced by each retry.
- Cancellation tokens and end-to-end deadlines propagate into the retry loop and abort outstanding attempts cleanly.
- Message or job retry flows have a maximum delivery-attempt limit and a dead-letter or poison-message route.
- SDK default retry policies are not silently stacked on top of application-level retry policies.
- A circuit breaker is present or explicitly considered when the target dependency has a history of extended outages.
- Logs, metrics, or tracing distinguish first-attempt failures from retried failures and record final retry exhaustion separately.
- Logging inside retry loops is at `debug` level or suppressed after the first attempt to prevent log floods under sustained failure.
- Dashboards or alerts exist for elevated retry rates, circuit-breaker open events, and retry budget exhaustion.

## Logging Signal And Severity
- Logs include enough context to trace a request or workflow, such as correlation identifiers, key operation metadata, and relevant boundaries.
- Logging volume is bounded to avoid log flood under high traffic, retries, loops, or repeated failures.
- Error paths that affect correctness, availability, security, or data integrity are logged at `error` with actionable context.
- Events currently logged as `warning` are reviewed to ensure true failures are promoted to `error` when they require immediate action.
- Events currently logged as `info` are reviewed to ensure failure conditions are not under-classified and hidden from operational response.
- Sensitive or regulated data is not leaked in logs, and redaction/masking rules are applied consistently.
- Structured logging fields are consistent so dashboards, alerts, and search queries remain reliable.
- Logs support both user impact analysis (failed actions, degraded experience) and service impact analysis (error rates, saturation, noisy retries).

## Queue Consumer Processing Safety
- Per-message logging is bounded and does not emit full payloads or high-cardinality fields at `info`/`warning` in steady-state traffic.
- The effective external dependency call count per message (HTTP, database, cache, filesystem) is mapped, bounded, and acceptable for expected throughput and replay/retry scenarios.
- Per-message HTTP calls use explicit timeout, bounded retry, and backoff rules that avoid downstream overload and retry storms.
- Per-message database access avoids N+1 and row-by-row amplification when batching or set-based writes/reads are possible.
- Consumer retry, requeue, and dead-letter behavior is explicit, bounded, and safe for poison-message scenarios.
- Idempotency and deduplication strategy is defined for at-least-once delivery and replay, especially for write side effects.
- Commit/ack timing is safe: offsets/acks are recorded only after required side effects succeed, with clear handling for partial failure.
- Concurrency, prefetch, and partition/worker parallelism are bounded to avoid pool exhaustion, rate-limit spikes, or downstream saturation.
- Ordering assumptions are explicit and validated where key-based ordering or exactly-once behavior is required.
- Backpressure and overload behavior is defined (pause, slow down, shed, defer) so backlog growth does not collapse dependent systems.
- Consumer health and lag signals are observable: queue lag, processing latency, retry rate, DLQ rate, commit failures, and per-message dependency latency.
- Security and privacy controls prevent sensitive message fields from being logged or sent unnecessarily to external dependencies.

## Skill to use
- Use `.github/skills/external-http-calls/SKILL.md` for the detailed review workflow and suggestions.
- Use `.github/skills/database-calls/SKILL.md` for the detailed database review workflow and suggestions.
- Use `.github/skills/dependency-call-impact/SKILL.md` for the detailed workflow on multiplied HTTP/database call impact.
- Use `.github/skills/comment-and-impact-validation/SKILL.md` for the detailed workflow on accidental commented-out code in final commits, intent clarity, and committed-change impact validation.
- Use `.github/skills/change-impact-validation/SKILL.md` for the detailed workflow on validating downstream and cross-area impact from code changes.
- Use `.github/skills/flag-and-env-validation/SKILL.md` for the detailed workflow on flag, config, and environment-variable safety, especially missing-value impact.
- Use `.github/skills/scalability-validation/SKILL.md` for the detailed workflow on capacity, hot-spot, overload, and scale-behavior review.
- Use `.github/skills/runtime-safety-and-staleness/SKILL.md` for the detailed workflow on runtime exceptions and stale-data risks.
- Use `.github/skills/cache-strategy-and-impact/SKILL.md` for the detailed workflow on cache design and cache impact.
- Use `.github/skills/resource-usage-and-lifecycle/SKILL.md` for the detailed workflow on CPU/memory usage and resource release safety.
- Use `.github/skills/logging-signal-and-severity/SKILL.md` for the detailed workflow on log traceability, severity correctness, and flood prevention.
- Use `.github/skills/retry-mechanism/SKILL.md` for the detailed workflow on retry loop safety, backoff quality, call amplification, idempotency, circuit-breaker review, and retry observability.
- Use `.github/skills/queue-consumer-processing-safety/SKILL.md` for the detailed workflow on queue/stream consumer safety, including per-message log volume, dependency call amplification, ack/commit correctness, retries, and DLQ behavior.