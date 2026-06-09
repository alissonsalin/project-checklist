---
name: exception-handling-safety
description: 'Review exception handling for unhandled failures, unsafe catch blocks, and missing boundaries that can cause runtime exceptions or service instability. Use when changes add or modify throw/catch logic, async flows, parsing, external inputs, or failure-path behavior.'
argument-hint: 'Describe the changed code path where exception handling may be missing, unsafe, or inconsistent.'
user-invocable: true
---

# Exception Handling Safety

Use this skill when a change can introduce unhandled exceptions or weak failure handling that may crash requests, workers, or processes.

This skill exists to catch missing exception boundaries, broad catch-and-ignore behavior, unsafe async exception handling, and inconsistent error translation that can turn ordinary faults into runtime outages.

## What to Review
- New or modified `throw`, `try/catch`, result/error wrappers, and global exception handlers.
- Async code (`async/await`, tasks, promises, callbacks) where exceptions may be dropped or observed too late.
- Parsing, deserialization, reflection, dynamic mapping, and config/flag reads that can throw at runtime.
- External dependency calls where errors should be translated, classified, retried, or surfaced consistently.
- Worker, queue, and background-job failure paths where one bad message/job can crash execution.

## Core Checks
1. Check exception boundaries.
   - Verify there is a deliberate boundary that converts low-level exceptions into safe application outcomes.
   - Flag unhandled exceptions in request handlers, consumers, schedulers, and startup paths.
   - Check that boundary placement avoids both process crash and silent data corruption.
2. Check catch-block quality.
   - Flag broad `catch (Exception)` or equivalent that swallows errors without action.
   - Verify caught exceptions are either rethrown, translated, or returned with actionable context.
   - Check that catch blocks preserve original exception details and stack trace where needed.
3. Check async exception safety.
   - Flag fire-and-forget tasks/promises where exceptions are never observed.
   - Verify awaited flows propagate cancellation and failure correctly.
   - Check that background and callback exceptions are routed to observable error channels.
4. Check failure classification and translation.
   - Verify transient vs permanent failures are handled differently.
   - Check domain/business errors are translated to stable, caller-safe contracts.
   - Flag raw dependency exceptions leaking through public boundaries without mapping.
5. Check fallback and degraded behavior.
   - Verify fallback paths preserve correctness and do not hide critical failure.
   - Check if retry/fallback loops can repeat failure indefinitely or amplify load.
   - Flag fallback results that mask hard errors without telemetry.
6. Check observability and diagnostics.
   - Verify exception paths emit useful `error` logs/metrics with correlation context.
   - Check repeated failures are visible via counters, alerts, or traces.
   - Flag exception flows where operators cannot distinguish transient noise from real outage.
7. Check tests for failure paths.
   - Verify tests cover unhandled-exception prevention at key boundaries.
   - Verify tests for parsing/config errors, dependency failure mapping, and async fault propagation.
   - Flag risky changes where only happy-path tests were updated.

## Suggestions To Consider
- Add explicit exception boundaries at service/controller/consumer entry points.
- Replace broad swallow patterns with typed handling and explicit fallback policy.
- Preserve root cause by logging with stack traces and stable error codes.
- Map dependency exceptions to domain-safe error contracts.
- Add cancellation and timeout propagation to async failure paths.
- Add dead-letter or quarantine behavior for poison messages in background processing.
- Add tests for malformed input, failed dependency calls, and asynchronous fault paths.
- Add alert thresholds for exception-rate spikes and repeated fallback activation.
- Add circuit-breaker or fast-fail behavior for repeated dependency exceptions.
- Add validation before risky parsing/mapping operations to reduce throw frequency.

## Red Flags
- Unhandled exception can terminate request, worker, or process.
- Catch block suppresses exception with no logging, no metric, and no compensation.
- Async task/promise failure is not awaited or observed.
- Raw framework or dependency exception leaks through public API boundaries.
- Re-throw loses original stack/context, making root-cause analysis difficult.
- Fallback silently returns success-like output for hard failures.
- Failure path lacks tests and operator-visible signals.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether exception safety is safe, warning-level, or blocking.
2. `Exception Boundary Assessment`
   - Explain whether exception boundaries and catch behavior are safe and deliberate.
3. `Failure Handling Assessment`
   - Explain classification, translation, fallback, and async failure-handling quality.
4. `Observability And Test Coverage`
   - Explain whether diagnostics and tests cover runtime failure paths.
5. `Suggestions`
   - List the smallest improvements that materially reduce runtime exception risk.

## Reference
- Use [exception-handling-safety-review](./references/exception-handling-safety-review.md) for a compact decision guide.
