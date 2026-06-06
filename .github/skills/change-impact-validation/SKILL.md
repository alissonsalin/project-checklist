---
name: change-impact-validation
description: 'Validate impacts in other parts of the codebase that can be affected by a change. Use when edits may affect callers, shared contracts, downstream modules, rollout compatibility, or behavior outside the touched files.'
argument-hint: 'Describe what changed and which callers, modules, contracts, or rollout paths might be impacted.'
user-invocable: true
---

# Change Impact Validation

Use this skill when a change may alter behavior outside the files directly edited.

This skill exists to catch hidden downstream regressions where local changes to shared contracts, defaults, side effects, or control flow break other code paths that were not modified in the same diff.

## What to Review
- Public API and internal contract changes: function signatures, interfaces, DTOs, schemas, events, config keys, CLI arguments.
- Shared library and utility changes consumed by multiple modules, services, jobs, or controllers.
- Behavior changes: defaults, ordering, filtering, validation rules, error mapping, timeout/retry behavior.
- Cross-cutting concerns: caching, logging, auth, serialization, feature flags, transaction boundaries.
- Data compatibility and rollout sequencing where old and new producers/consumers may coexist.
- Test coverage changes that should include at least one downstream integration path.

## Core Checks
1. Map the impact surface.
   - Identify the changed symbols, contracts, and behavior.
   - Find known callers and consumers likely affected.
   - Flag high-blast-radius symbols (shared interfaces, base classes, utility modules).
2. Validate caller compatibility.
   - Verify signature and contract changes are reflected in all impacted call sites.
   - Check optional/required field changes for both producers and consumers.
   - Check default values and nullability assumptions across call boundaries.
3. Validate behavior compatibility.
   - Check if ordering, filtering, validation, retry, or timeout changes alter downstream expectations.
   - Check if error type/status mapping changes break existing handling paths.
   - Flag behavior that changed silently without explicit migration or release note.
4. Validate data and rollout compatibility.
   - Verify schema and payload changes remain safe during mixed-version rollout.
   - Check backward and forward compatibility of reads/writes.
   - Check migration sequencing, feature flags, and rollback behavior.
5. Validate side effects in shared concerns.
   - Check cache key, invalidation, and freshness assumptions across dependent flows.
   - Check logging or metrics changes that could hide signals used by other teams.
   - Check auth and permission checks for broadened or narrowed access.
6. Validate test and evidence coverage.
   - Ensure unit tests cover changed behavior.
   - Ensure at least one integration or end-to-end path covers downstream impact.
   - Flag missing tests for impacted consumers.
7. Validate ownership and follow-up.
   - If full validation is not possible from the diff, require explicit owner questions.
   - Record concrete follow-up actions for unresolved impacts before merge.

## Suggestions to Consider
- Add or update contract tests for shared interfaces and payload schemas.
- Add compatibility guards when introducing new required fields or enum values.
- Introduce feature flags or dual-read/dual-write rollout for risky compatibility changes.
- Add deprecation shims for renamed or removed APIs.
- Update downstream integration tests for at least one representative impacted caller.
- Add targeted release notes for behavior changes that may surprise consumers.
- Add static analysis or CI checks for critical shared contracts.

## Red Flags
- Shared interface change without auditing or updating all known consumers.
- Removed/renamed config keys or DTO fields without compatibility handling.
- Changed default behavior with no downstream tests.
- Error mapping changed in a way that bypasses existing retry/fallback logic.
- Schema changes that are not safe for rolling deployments.
- Feature flag changes that expose unfinished behavior on unrelated paths.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether cross-area impact is safe, warning-level, or blocking.
2. `Impacted Surface`
   - List contracts, symbols, and modules likely affected outside edited files.
3. `Compatibility Assessment`
   - Explain caller, data, and behavior compatibility risk.
4. `Evidence`
   - Provide concrete changed locations and the downstream implications.
5. `Suggestions`
   - List the smallest actions to reduce unresolved impact risk before merge.

## Reference
- Use [change-impact-validation-review](./references/change-impact-validation-review.md) for a compact decision guide.