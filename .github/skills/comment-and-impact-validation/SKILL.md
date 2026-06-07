---
name: comment-and-impact-validation
description: 'Review changed code for accidentally commented-out executable logic left in final commits, and validate committed-change impact across callers, modules, and operations.'
argument-hint: 'Describe the changed code path and where disabled-in-comment code or downstream impact may create risk.'
user-invocable: true
---

# Comment And Impact Validation

Use this skill when a commit may include executable code accidentally left commented out, or behavior changes that could cause issues if impact is not clear.

This skill exists to catch production risk from two related gaps:
- executable logic commented during development and forgotten in the final commit
- behavior changes merged without validating downstream impact on callers, modules, and operations

## What to Review
- Newly added or modified comment blocks and single-line comments that resemble executable code.
- Diff hunks where active code was replaced by comments, especially around guards, retries, feature flags, and error handling.
- Hotfix branches, temporary mitigations, one-off workarounds, and code with hidden assumptions.
- Public or shared behavior changes that can affect other files even if those files are not edited in the same diff.
- Code where removed comments may have eliminated critical intent, safety assumptions, or operational context.
- Evidence that changed behavior was validated for downstream use cases before merge.

## Core Checks
1. Detect accidentally commented-out code.
   - Flag comments that contain executable statements, function calls, control flow, SQL, or return paths likely intended to run.
   - Compare nearby history in the diff to detect active code replaced by comments without clear rationale.
   - Distinguish legitimate examples/docs from disabled runtime logic by checking surrounding context.
2. Validate safety assumptions are documented.
   - Check whether assumptions about ordering, idempotency, eventual consistency, or side effects are stated.
   - Check whether boundary conditions and failure-mode expectations are clear to future maintainers.
   - Flag silent assumptions that can cause regressions after refactoring.
3. Validate temporary code path discipline.
   - Check temporary disabled code for removal criteria, owner, or follow-up reference.
   - Flag commented-out code kept as TODO with no action owner or timeline.
   - Flag temporary logic that appears permanent without rationale.
4. Validate committed-change impact.
   - Identify caller, consumer, or operator flows affected by behavior or contract changes.
   - Check whether downstream modules were updated or explicitly listed for follow-up.
   - Check whether defaults, error mapping, or side effects changed outside the edited file.
5. Validate evidence quality.
   - Look for tests, compatibility checks, or release notes that cover the changed behavior.
   - Flag impact claims without concrete validation evidence.
   - Ensure unresolved impacts have owner and next action before merge.
6. Validate comment hygiene.
   - Flag stale or misleading comments that now contradict code behavior.
   - Flag removed comments when replacement code is not sufficiently self-explanatory.
   - Flag commented-out code retained as notes when it should be deleted or converted into issue-tracked follow-up.

## Suggestions To Consider
- Remove commented-out executable code from final commit when it is not intentionally retained.
- If temporary retention is necessary, add owner, tracking issue, and cleanup criteria in the comment.
- Restore required executable behavior and add tests when code was accidentally disabled in comments.
- Add one-line intent comments above non-obvious business or failure-handling branches.
- Add a short comment for assumptions that are critical for correctness under retries, ordering, or eventual consistency.
- Add follow-up owner and tracking reference for temporary workaround paths.
- Add or update one integration test for the most likely impacted downstream path.
- Add release note or migration note for behavior changes in shared APIs or workflows.
- Remove or rewrite stale comments so code and documentation are aligned.

## Red Flags
- Executable code is present in comments on a runtime path with no explicit temporary justification.
- A commit disables validation, authorization, retry, or error handling by commenting out active logic.
- Commented-out code changes behavior but no downstream impact validation is documented.
- Removed comments from critical paths while readability and intent became unclear.
- Workaround or hotfix logic with no expiry plan or owner.
- Behavior change in shared code with no downstream caller validation.
- No test or verification evidence for claimed safe impact.
- Comment says one thing while code does another.

## Review Output
Return findings under these headings:

1. `Risk`
   - State whether comment/impact quality is safe, warning-level, or blocking.
2. `Commented-Out Code Assessment`
   - Explain whether comments contain accidentally disabled executable logic.
3. `Committed-Change Impact Assessment`
   - Explain downstream impact and compatibility risk from the merged behavior.
4. `Evidence`
   - Provide concrete changed locations and why they are risky or sufficiently validated.
5. `Suggestions`
   - List the smallest fixes to improve safety before merge.

## Reference
- Use [comment-and-impact-validation-review](./references/comment-and-impact-validation-review.md) for a compact decision guide.
