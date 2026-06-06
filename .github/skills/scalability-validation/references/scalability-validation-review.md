# Scalability Validation Review Reference

Use this compact guide when reviewing whether a change stays safe as load, data volume, tenant count, or batch size increases.

## Quick Triage
- Review this skill when the change alters throughput, concurrency, batching, partitioning, queueing, worker counts, request hot paths, or large-data processing.
- Escalate quickly when a path can become a hot spot, build backlog, or fail without overload controls.

## Fast Questions
1. What is the growth dimension for this path: request rate, item count, queue depth, tenant count, or batch size?
2. Does the work stay bounded and proportional as that dimension increases?
3. Can one key, tenant, shard, or worker become the bottleneck?
4. What happens at saturation: shed work, slow safely, queue briefly, or collapse broadly?
5. Do telemetry or tests show tail latency, backlog, and skew before production impact?

## Blocking Patterns
- Unbounded work per request, job, or batch with no explicit guardrail.
- Single-partition or single-tenant hot spots likely under realistic traffic.
- No backpressure, queue cap, or admission control on a burst-prone path.
- Recovery behavior that can replay backlog fast enough to overload dependencies.
- Scalability claims with no telemetry or test evidence for the stated load shape.

## Warning Patterns
- Tail-latency risk is plausible but not measured.
- Partition skew is possible but only partially mitigated.
- Concurrency is bounded, but limits are undocumented or not tied to dependency capacity.
- Load handling depends on autoscaling alone without local shedding or queue limits.

## Review Prompt
- State the scaling dimension and likely first bottleneck.
- State whether throughput, latency, and backlog remain acceptably bounded.
- State whether overload and recovery behavior are defined.
- Suggest the smallest guardrail, telemetry, or test that would reduce uncertainty.