# Runtime Safety And Stale Data Review Guide

## Runtime Safety Questions
- Can this value be null, missing, empty, malformed, or from a future schema version?
- What happens if the collection is empty or the key is absent?
- Can parsing, mapping, casting, or template rendering fail here?
- Can async timing or disposal make this object invalid before use?

## Freshness Questions
- Is this read coming from a cache, replica, snapshot, or eventually consistent model?
- Does this business action require the latest committed state?
- What happens if the cached or replicated value is behind by seconds or minutes?
- Can two writers overwrite each other without a version check?

## Expectations
- Trust boundaries validate data before use.
- Critical decisions avoid stale reads unless the tradeoff is explicit and acceptable.
- Concurrent updates detect conflicts.
- Runtime edge cases are observable and tested.

## Useful Checks To Add
- Null and malformed-input tests.
- Empty-collection and missing-key tests.
- Concurrency-conflict tests.
- Cache-lag or replica-lag tests.
- Unknown-enum or future-schema compatibility tests.