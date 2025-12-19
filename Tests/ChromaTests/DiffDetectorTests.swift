import Testing
@testable import Chroma

@Suite("DiffDetector")
struct DiffDetectorTests {
    @Test("Detects patch-like input")
    func looksLikePatch() {
        let patch = "diff --git a/Foo.swift b/Foo.swift\n@@ -1 +1 @@\n"
        let plain = "struct User {}\n"

        #expect(DiffDetector.looksLikePatch(patch))
        #expect(!DiffDetector.looksLikePatch(plain))
    }

    @Test("Classifies diff line kinds")
    func lineKinds() {
        #expect(DiffDetector.kind(forLine: "diff --git a/Foo b/Foo") == .meta)
        #expect(DiffDetector.kind(forLine: "index 111..222") == .meta)
        #expect(DiffDetector.kind(forLine: "Binary files a and b differ") == .meta)
        #expect(DiffDetector.kind(forLine: "@@ -1,1 +1,1 @@") == .hunkHeader)
        #expect(DiffDetector.kind(forLine: "--- a/Foo.swift") == .fileHeader)
        #expect(DiffDetector.kind(forLine: "+++ b/Foo.swift") == .fileHeader)
        #expect(DiffDetector.kind(forLine: "+let a = 1") == .added)
        #expect(DiffDetector.kind(forLine: "-let a = 1") == .removed)
        #expect(DiffDetector.kind(forLine: " let a = 1") == nil)
    }

    @Test("splitLines preserves trailing line")
    func splitLinesPreservesTrailing() {
        let lines = splitLines("a\nb")
        #expect(lines.count == 2)
        #expect(lines[0] == "a")
        #expect(lines[1] == "b")
    }

    @Test("trimmingCR drops carriage return")
    func trimmingCarriageReturn() {
        let line: Substring = "line\r"
        #expect(trimmingCR(line) == "line")
    }
}
