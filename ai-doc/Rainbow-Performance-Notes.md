# Rainbow Performance Notes (for Chroma)

## Context
Chroma benchmarks showed that `Rainbow.enabled = false` was not faster than `true`. The baseline “Rainbow off” path in Chroma used `Rainbow.Entry.plainText`, which currently concatenates strings using `reduce("", +)` in Rainbow. That pattern is O(n^2) in total string length and can be slower than the ANSI path that preallocates and appends.

## Findings
- `Rainbow.Entry.plainText` implementation (as of Rainbow 4.2.0) uses `segments.reduce("") { $0 + $1.text }`.
- When `Rainbow.enabled == false`, Chroma previously returned `entry.plainText`, making the “no color” path slower in practice.
- A temporary fast path in Chroma (prealloc + append) makes “Rainbow off” slightly faster than “on”.

## Evidence (local benchmark)
Using package-benchmark:

```
BENCHMARK_DISABLE_JEMALLOC=1 swift package benchmark --target ChromaBenchmarks
```

Example run (p50 wall clock on one machine):
- Highlight Swift (Rainbow off): ~187 ms
- Highlight Swift (Rainbow on):  ~193 ms

Before the fast path, “Rainbow off” was often equal or slower than “on”.

## Proposed Rainbow Change
Replace `plainText` with a linear append implementation:

```swift
public var plainText: String {
    var result = String()
    result.reserveCapacity(segments.reduce(0) { $0 + $1.text.utf8.count })
    for segment in segments {
        result.append(segment.text)
    }
    return result
}
```

Expected impact:
- `Rainbow.enabled == false` becomes consistently faster and more predictable.
- Chroma can remove its temporary bypass and rely on `Rainbow.Entry.plainText` again.

## Notes
- The current Chroma fast path is a local workaround to validate the hypothesis.
- After Rainbow is optimized, we should revert Chroma’s workaround and just bump the dependency.
