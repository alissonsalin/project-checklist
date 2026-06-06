---
name: scalability-validation
description: 'Validate scalability risks when changes can alter throughput limits, hot-path cost, partitioning behavior, overload handling, or system behavior under larger traffic, data, or batch sizes.'
argument-hint: 'Describe the changed flow and where higher traffic, larger datasets, or larger batches could change behavior.'
user-invocable: true
---

# Scalability Validation

Use this skill when a change may affect how the system behaves as traffic, data size, tenant count, concurrency, queue depth, or batch size grows.

This skill exists to catch scale risks that are easy to miss in small test cases, such as hot partitions, lock contention, overload collapse, queue buildup, tail-latency spikes, uneven work distribution, and cost or saturation cliffs that only appear at higher volume.

## What to Review
- Request paths, jobs, and batch flows whose cost may grow with input size or traffic.
- Changes to concurrency, worker counts, batching, buffering, partitioning, queueing, or scheduling.
- Hot-key, hot-tenant, or hot-partition access patterns in cache, storage, queues, or databases.
- Fan-out or aggregation logic that can amplify load as traffic rises.
- Admission control, backpressure, timeouts, degraded-mode handling, and overload recovery behavior.
- Telemetry, load tests, and capacity assumptions used to justify the change.

## Core Checks
1. Check scaling dimension and growth function.
   - Identify what grows: request rate, item count, tenant count, shard size, queue depth, or batch size.
   - Estimate how CPU, memory, I/O, lock contention, and dependency usage grow with that dimension.
   - Flag growth that is unbounded, super-linear, or hidden behind small local test inputs.
2. Check hot-path cost and tail latency.
   - Flag new serialization, parsing, sorting, joins, scans, or locking in latency-sensitive paths.
   - Check whether p95 and p99 latency can degrade sharply even if median latency stays acceptable.
   - Flag synchronous work on the request path that should move to batch or background processing.
3. Check distribution, partitioning, and hot-spot risk.
   - Verify keys, shards, partitions, and work assignment spread load evenly enough.
   - Flag hot tenants, hot keys, sequential partition keys, or leader bottlenecks.
   - Check whether one node, queue, table, or downstream dependency can become the dominant bottleneck.
4. Check concurrency and throughput controls.
   - Verify worker count, queue consumers, and parallel execution are bounded and capacity-aware.
   - Flag scaling decisions that increase throughput by borrowing too much latency, memory, or pool capacity.
   - Check whether retries, replays, or catch-up behavior create burst amplification after partial outage.
5. Check overload behavior and recovery.
   - Verify backpressure, queue limits, timeouts, admission control, and shedding exist where load can spike.
   - Flag designs that fail open and keep accepting work after saturation begins.
   - Check whether recovery from backlog causes another surge or long tail of degraded service.
6. Check user and service impact explicitly.
   - User impact: assess timeouts, tail latency, fairness across tenants, and correctness under load.
   - Service impact: assess saturation, unstable autoscaling, backlog growth, node imbalance, and infra cost.
   - Flag tradeoffs where throughput improves but overload safety or fairness regresses.
7. Check evidence and observability.
   - Ensure telemetry can show request rate, queue depth, worker utilization, saturation, tail latency, and partition skew.
   - Prefer load-test, benchmark, or production-capacity evidence for meaningful scale changes.
   - Flag changes whose safety depends on scale assumptions that are undocumented or unmeasured.

## Suggestions To Consider
- Add or document explicit throughput, queue-depth, and latency budgets for the changed path.
- Add bounded concurrency, admission control, or work shedding before saturation cascades.
- Repartition keys or work assignment to avoid hot-spot concentration.
- Move expensive aggregation or enrichment off the request path.
- Add batch-size, page-size, or payload-size guardrails.
- Add catch-up limits so retries or backlog drain do not create recovery storms.
- Add tenant fairness controls when one tenant can dominate shared capacity.
- Add dashboards for p95/p99 latency, saturation, queue depth, backlog age, and partition skew.
- Add load tests for peak traffic, skewed-key traffic, recovery after outage, and oversized batches.
- Document expected scale envelope and the first bottleneck expected to appear.

## Red Flags
- Request or job cost grows directly with unbounded dataset or batch size.
- A single tenant, partition, queue, or leader can dominate throughput.
- Throughput increase depends on unbounded concurrency or queue growth.
- Recovery behavior floods dependencies after outage or deploy.
- No overload control exists on a path that can receive burst traffic.
- Tail latency or backlog growth cannot be observed with existing telemetry.
- Scale justification relies only on local correctness tests with no capacity evidence.
- Cost or saturation shifts to another dependency without explicit acknowledgement.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether the change is safe, warning-level, or blocking.
2. `Scalability Assessment`
   - Explain whether the changed path remains acceptably bounded as load and data size grow.
3. `Hot-Spot And Overload Assessment`
   - Explain whether distribution, concurrency, backpressure, and recovery controls are adequate.
4. `User And Service Impact`
   - Explain expected impact on latency, fairness, saturation, and operating cost under higher load.
5. `Suggestions`
   - List the smallest improvements that would materially reduce scale risk.

## Reference
- Use [scalability-validation-review](./references/scalability-validation-review.md) for a compact decision guide.