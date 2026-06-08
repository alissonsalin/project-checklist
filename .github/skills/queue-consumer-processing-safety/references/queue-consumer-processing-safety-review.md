# Queue Consumer Processing Safety Review Guide

## Primary Questions
- How much work does one message trigger in normal flow and worst-case retry flow?
- How many logs does one message generate at steady-state traffic?
- Are external API and database calls per message bounded, timed out, and retry-safe?
- Is ack/commit timing safe for partial failure and replay?
- Can poison messages escape to DLQ instead of looping forever?

## Throughput And Cost Expectations
- Treat per-message HTTP and database calls as multiplicative cost at consumer throughput.
- Prefer batching, set-based access, and bounded fan-out over one-call-per-message patterns.
- Ensure replay and backlog catch-up do not exceed downstream capacity.
- Bound concurrency and prefetch to pool and rate-limit realities.

## Log Quality Expectations
- Avoid per-message `info`/`warning` logs in hot paths.
- Avoid full payload logging and high-cardinality fields.
- Keep retry-loop noise low with sampling or first-and-final-attempt logging.
- Preserve traceability using correlation/message ids in structured fields.

## Delivery Safety Expectations
- Use bounded retries with backoff and jitter.
- Use idempotency or deduplication for at-least-once delivery.
- Commit/ack only after required durable side effects succeed.
- Define DLQ policy and operator recovery path for poison messages.

## Useful Questions
- What happens during a dependency slowdown while backlog is growing?
- What happens when the same message is delivered multiple times?
- What is the maximum downstream call volume during replay?
- Which logs are still emitted when throughput is 10x?
- Which metrics and alerts fire before saturation becomes customer-visible?