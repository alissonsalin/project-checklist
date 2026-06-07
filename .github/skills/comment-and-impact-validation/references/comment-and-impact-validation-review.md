# Comment And Impact Validation Review Guide

## Commented-Out Code Questions
- Does this comment contain executable statements that look like runtime logic?
- Was active code replaced by comments in this diff without explicit temporary rationale?
- Is the commented snippet a real example/doc, or disabled production behavior?
- If temporary, does it include owner, tracking issue, and cleanup criteria?

## Intent Clarity Questions
- Is this code path non-obvious to a maintainer seeing it for the first time?
- Does this branch implement unusual business logic, fallback, or compensation behavior?
- If comments were removed, is intent still clear from naming and structure alone?
- Are critical assumptions documented where misunderstanding could cause incidents?

## Committed-Change Impact Questions
- Which callers, modules, jobs, or operators are affected by this behavior change?
- Did defaults, error mapping, side effects, or ordering change for downstream flows?
- Are known consumers updated, or at least explicitly listed for follow-up?
- Is there compatibility risk during mixed-version rollout?

## Evidence Expectations
- Affected paths are identified explicitly.
- Commented-out executable code is either removed or explicitly justified and tracked.
- Non-obvious risky logic has concise intent comments.
- Temporary workaround paths have owner and follow-up.
- At least one targeted test or validation artifact supports impact claims.

## Useful Checks To Add
- One lint or grep check for likely commented-out executable code patterns in changed files.
- One integration test for the highest-risk downstream caller.
- One regression test for changed fallback or failure path behavior.
- One short release or migration note for shared behavior changes.
- One cleanup task for temporary workaround removal criteria.
