# Database Call Review Guide

## Retry Decision Guide
- Retry: dropped connection, transient failover, deadlock victim, serialization conflict, short lock timeout when the operation is safe to repeat.
- Usually do not retry: syntax error, schema mismatch, constraint violation, authentication failure, authorization failure, deterministic business-rule failure.
- Retry writes only when commit ambiguity, duplicate effects, and transaction boundaries are safely handled.

## Backoff Expectations
- Prefer bounded exponential backoff.
- Add jitter when many callers may retry together.
- Set a maximum attempt count.
- Set a maximum reconnect delay and overall time budget.
- Avoid layered retries across driver, ORM, and application code.

## Transaction Expectations
- Keep transactions short.
- Do not wait on outbound network calls while a transaction is open.
- Ensure rollback, retry, or compensation behavior is explicit.
- Ensure statement and transaction timeouts are configured.

## Health Expectations
- Liveness should usually reflect whether the process is functioning, not whether every query succeeds.
- Readiness can depend on the primary database only when the service cannot safely serve traffic without it.
- Optional projections, read models, analytics stores, or maintenance tasks should not trigger restart loops.

## Useful Questions
- What happens if the database is slow for 10 minutes?
- What happens if every worker retries the same deadlocked transaction at once?
- Can this retry duplicate a write or cross an ambiguous commit boundary?
- Can pool exhaustion block unrelated request handling?
- Can part of the service degrade safely instead of failing health probes?