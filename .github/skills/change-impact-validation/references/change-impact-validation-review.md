# Change Impact Validation Review

Use this quick guide to validate whether a local code change creates risk in other parts of the codebase.

## Quick Gate
- Did any shared contract or behavior change?
- Are known callers and consumers verified for compatibility?
- Are mixed-version rollout and rollback paths safe?
- Is there downstream test evidence for at least one impacted path?

If any answer is no or unknown, add a finding and a developer question.

## High-Risk Change Types
- Shared interface/signature changes.
- DTO, schema, or event payload changes.
- Defaults, validation, ordering, timeout, and retry behavior changes.
- Cache, auth, logging, and transaction behavior changes in shared components.
- Config/flag changes with broad blast radius.

## Minimum Evidence
- Specific changed location and what contract/behavior changed.
- At least one impacted caller or module that could regress.
- Compatibility posture: backward, forward, or mixed-version unsafe.
- Test coverage note: present, missing, or partial for downstream impact.

## Severity Hints
- `high`: likely break in known downstream callers or unsafe rollout compatibility.
- `medium`: plausible regression with incomplete caller validation or weak tests.
- `low`: contained impact with clear compatibility handling and minor residual risk.
- `info`: no actionable risk, documentation or minor hardening suggestions only.