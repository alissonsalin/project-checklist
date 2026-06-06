# Flag And Env Validation Review

Use this quick guide to validate whether flag or environment-variable changes are safe when values are missing or inconsistent.

## Quick Gate
- Was every new, renamed, or removed flag/env var identified and wired into deployment configuration?
- Is behavior safe when the value is missing, empty, malformed, or only present in some environments?
- Are defaults explicit and safe for security, correctness, and availability?
- Is there test or runtime evidence that configuration failures will be visible quickly?

If any answer is no or unknown, add a finding and a developer question.

## High-Risk Change Types
- New required env vars with no startup validation.
- Renamed or removed flags during rolling deployment.
- Defaults that enable risky behavior or disable protections.
- Raw parsing of bools, enums, numbers, durations, or URLs without validation.
- Shared settings read by multiple services or jobs without rollout coordination.

## Minimum Evidence
- Specific changed location and which flag/env var was added, removed, or modified.
- Missing-value behavior: crash, fallback, degraded mode, or safe fail-fast.
- Deployment/configuration impact: where the new value must be set.
- Test or observability note covering invalid or missing configuration.

## Severity Hints
- `high`: missing or renamed setting likely breaks startup, disables a critical safeguard, or creates unsafe production behavior.
- `medium`: default or parsing behavior is risky but likely contained or recoverable.
- `low`: mostly documented and safe, with minor rollout or observability gaps.
- `info`: no actionable risk, only documentation or minor hardening suggestions.