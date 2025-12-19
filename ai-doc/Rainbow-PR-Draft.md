# Rainbow PR Draft: Optimize Entry.plainText

## Summary
Improve `Rainbow.Entry.plainText` to build the string using preallocated linear appends instead of repeated concatenation. This makes the `Rainbow.enabled == false` path faster and more predictable.

## Motivation
Chroma benchmarks show that disabling Rainbow can be as slow or slower than enabling it. The root cause is `plainText` using `segments.reduce("", +)`, which is O(n^2) due to repeated string allocations. The ANSI path already preallocates and appends, so it can be faster.

## Proposed Change
Replace the current `plainText` implementation with a linear builder:

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

## Expected Impact
- Faster `Rainbow.enabled == false` output for large segmented strings.
- More consistent performance across enabled/disabled modes.

## Benchmark Evidence (from Chroma)
Command:

```
BENCHMARK_DISABLE_JEMALLOC=1 swift package benchmark --target ChromaBenchmarks
```

Example run (p50 wall clock):
- Highlight Swift (Rainbow off): ~187 ms
- Highlight Swift (Rainbow on):  ~193 ms

Before the workaround, “Rainbow off” was frequently equal or slower than “on”.

## Tests
- No dedicated Rainbow tests added yet; this is a performance-only change.
- Suggested validation: rerun benchmarks in Chroma and optionally add a microbenchmark in Rainbow if desired.
