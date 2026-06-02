# External HTTP Call Review Guide

## Retry Decision Guide
- Retry: connection reset, DNS/transient network failure, timeout, `429`, `502`, `503`, `504`.
- Usually do not retry: `400`, `401`, `403`, `404`, schema errors, business-rule failures.
- Retry writes only when idempotency is guaranteed by contract, idempotency key, or durable deduplication.

## Backoff Expectations
- Prefer exponential backoff.
- Add jitter to avoid synchronized retries.
- Set a maximum attempt count.
- Set a maximum delay and an end-to-end time budget.

## Health Expectations
- Liveness should usually reflect whether the process can run, not whether every dependency is healthy.
- Readiness can depend on critical dependencies, but only when traffic really must stop.
- Optional external services should degrade features rather than trigger restart loops.

## Useful Questions
- What happens if the downstream service is slow for 10 minutes?
- What happens if every instance retries at the same time?
- Can a single bad dependency make the service fail health probes?
- Is the operation safe to repeat?
- Can users or queues absorb temporary degradation instead of failing hard?