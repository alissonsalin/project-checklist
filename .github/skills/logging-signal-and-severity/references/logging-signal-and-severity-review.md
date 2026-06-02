# Logging Signal And Severity Review Guide

## Traceability Questions
- Can we follow one user request end-to-end using correlation fields?
- Do logs show key boundaries: start, dependency call, failure, and completion?
- Do error logs identify operation, dependency, and outcome clearly?

## Signal-Noise Questions
- Could this change flood logs under retries, loops, or traffic spikes?
- Are repeated failure logs sampled, deduplicated, or rate-limited?
- Are low-value info logs crowding useful operational signals?

## Severity Questions
- Is any true failure currently classified as `info` or `warning`?
- Which warnings should be errors because they represent failed outcomes?
- Which info events should be errors because users are impacted?

## Safety And Consistency
- Structured fields should be stable and queryable.
- Sensitive data should be redacted or omitted.
- Error logs should support alerting and runbook actions.