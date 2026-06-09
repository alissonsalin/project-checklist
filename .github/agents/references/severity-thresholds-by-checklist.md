# Severity Thresholds By Checklist

Use this reference to classify findings consistently across checklist areas.

## Global Baseline

| Type | Description | Severity |
| --- | --- | --- |
| Global Baseline | Direct risk of data corruption, security exposure, duplicate irreversible side effects, or broad outage with no effective mitigation. | critical |
| Global Baseline | Plausible major reliability, correctness, or capacity incident in production, especially on shared or hot paths. | high |
| Global Baseline | Real risk that is bounded by scale, path frequency, or partial safeguards, but still requires action. | medium |
| Global Baseline | Mainly observability, maintainability, or operational clarity gap with limited immediate incident risk. | low |
| Global Baseline | Coverage gap, clarification request, or improvement recommendation with no confirmed violation. | info |

## External HTTP Calls

| Type | Description | Severity |
| --- | --- | --- |
| External HTTP Calls | Infinite retries, non-idempotent write retries without safeguards, or missing timeout on critical path causing outage risk. | critical |
| External HTTP Calls | Tight-loop retries without bounded backoff/jitter, nested retry amplification, or health/startup coupled to non-critical dependency. | high |
| External HTTP Calls | Retry/backoff policy is incomplete but bounded by timeout or low-frequency execution. | medium |
| External HTTP Calls | Missing telemetry detail or weak error context while resilience behavior is mostly safe. | low |
| External HTTP Calls | Optional improvement suggestions such as bulkhead, circuit breaker, or dashboard enrichment. | info |

## Database Calls

| Type | Description | Severity |
| --- | --- | --- |
| Database Calls | Ambiguous commit retries that can duplicate writes or corrupt state, or no timeout with lock/wait amplification risk. | critical |
| Database Calls | Pool exhaustion risk, immediate reconnect loops, retries on deterministic failures, or unsafe transaction retry pattern. | high |
| Database Calls | Incomplete retry/backoff or timeout tuning with partial safeguards and bounded use. | medium |
| Database Calls | Weak deadlock/timeout telemetry or diagnostics quality issue. | low |
| Database Calls | Follow-up recommendation with no active correctness or reliability violation. | info |

## Dependency Call Impact

| Type | Description | Severity |
| --- | --- | --- |
| Dependency Call Impact | Unbounded fan-out on hot path with clear collapse risk, or retry amplification explosion under failure. | critical |
| Dependency Call Impact | Large burst fan-out without concurrency limiter, N+1 on hot path, or user-controlled scale amplification. | high |
| Dependency Call Impact | Fan-out exists but is bounded, low-frequency, or partially throttled. | medium |
| Dependency Call Impact | Efficiency concern with limited immediate operational impact. | low |
| Dependency Call Impact | Improvement suggestions for batching, caching, or memoization. | info |

## Comment And Impact Validation

| Type | Description | Severity |
| --- | --- | --- |
| Comment And Impact Validation | Critical-path executable logic is accidentally left commented out in final commit, or disabled code causes unmitigated outage/correctness risk. | critical |
| Comment And Impact Validation | Commented-out runtime logic or shared-contract behavior change lacks explicit justification and likely impacts downstream callers without validation. | high |
| Comment And Impact Validation | Commented-out code or impact evidence is incomplete but bounded to lower-frequency paths or partially validated scenarios. | medium |
| Comment And Impact Validation | Maintainability or documentation quality gap with limited immediate incident risk. | low |
| Comment And Impact Validation | Optional improvement suggestion for comment hygiene or impact traceability. | info |

## Runtime Safety And Stale Data

| Type | Description | Severity |
| --- | --- | --- |
| Runtime Safety And Stale Data | Stale data used for critical business decisions, lost-update risk, or crash-prone unsafe assumptions on common path. | critical |
| Runtime Safety And Stale Data | Likely null/type/index/runtime failure on common path, race condition with production plausibility, or unsafe read-after-write expectation. | high |
| Runtime Safety And Stale Data | Edge-case runtime risk or stale-read risk with bounded business impact and partial controls. | medium |
| Runtime Safety And Stale Data | Test/telemetry gap for edge-case detection. | low |
| Runtime Safety And Stale Data | Clarification needed for freshness requirements or assumptions. | info |

## Cache Strategy And Impact

| Type | Description | Severity |
| --- | --- | --- |
| Cache Strategy And Impact | Tenant/user data mixing, stale critical decision data, or outage fallback that can collapse primaries at service scale. | critical |
| Cache Strategy And Impact | Missing invalidation with user-visible correctness impact, no herd protection on hot keys, or topology mismatch causing inconsistency incidents. | high |
| Cache Strategy And Impact | TTL/invalidation weaknesses with bounded impact or recoverable fallback cost. | medium |
| Cache Strategy And Impact | Cache telemetry or dashboard quality issue without immediate correctness risk. | low |
| Cache Strategy And Impact | Optional optimization guidance such as warming, stale-while-revalidate, or key versioning. | info |

## Resource Usage And Lifecycle

| Type | Description | Severity |
| --- | --- | --- |
| Resource Usage And Lifecycle | Unbounded growth or leak that can destabilize process, or runaway CPU loop. | critical |
| Resource Usage And Lifecycle | High-risk resource churn or accumulation on common paths such as fire-and-forget leaks or per-request heavy client creation. | high |
| Resource Usage And Lifecycle | Resource cleanup or performance issues limited to specific paths or stress scenarios. | medium |
| Resource Usage And Lifecycle | Minor inefficiency or missing soak/monitoring evidence. | low |
| Resource Usage And Lifecycle | Optimization or observability enhancement suggestion only. | info |

## Logging Signal And Severity

| Type | Description | Severity |
| --- | --- | --- |
| Logging Signal And Severity | Sensitive data exposure in logs, or systematic masking of true critical failures. | critical |
| Logging Signal And Severity | True failures logged below error, silent failure paths, or log flood risk that can impair operations during incidents. | high |
| Logging Signal And Severity | Misclassification/noise issues that degrade response quality but are not immediately incident-driving. | medium |
| Logging Signal And Severity | Field consistency or diagnostic quality gaps. | low |
| Logging Signal And Severity | Suggested structured logging improvements with no confirmed risk. | info |

## Promise Resource Retention Safety

| Type | Description | Severity |
| --- | --- | --- |
| Promise Resource Retention Safety | Promise can remain unresolved indefinitely on common path, causing unbounded memory/resource retention or process destabilization. | critical |
| Promise Resource Retention Safety | Unhandled promise rejection, missing exception-path cleanup, or unbounded in-flight async fan-out with likely production impact. | high |
| Promise Resource Retention Safety | Promise lifecycle or cleanup weakness exists but is bounded by low-frequency path, limits, or partial safeguards. | medium |
| Promise Resource Retention Safety | Telemetry, diagnostics, or test coverage gap for promise failure/retention behavior. | low |
| Promise Resource Retention Safety | Optional async lifecycle improvement suggestion with no confirmed reliability violation. | info |

## Checklist Coverage Gap And Process Guardrails

| Type | Description | Severity |
| --- | --- | --- |
| Checklist Coverage Gap And Process Guardrails | Enforcement can be bypassed silently while appearing active. | critical |
| Checklist Coverage Gap And Process Guardrails | Commit/review gate can pass or block incorrectly in normal workflow. | high |
| Checklist Coverage Gap And Process Guardrails | Enforcement works but is fragile across common environments. | medium |
| Checklist Coverage Gap And Process Guardrails | Documentation or portability quality gap. | low |
| Checklist Coverage Gap And Process Guardrails | Proposal for additional checklist scope. | info |

## Severity Modifiers

| Type | Description | Severity |
| --- | --- | --- |
| Severity Modifiers | Shared component, hot path, user-controlled scale, retry/fan-out multiplication, startup/readiness path, or missing mitigation. | escalate +1 |
| Severity Modifiers | Hard bounds, low-frequency execution, explicit business acceptance, and telemetry evidence proving acceptable behavior. | de-escalate -1 |
| Severity Modifiers | Red-flag conditions in a checklist should not be scored below medium unless explicit evidence justifies it. | severity floor |
| Severity Modifiers | Any critical or high finding must result in blocked verdict per agent verdict rules. | block rule |
