public struct LineRangeSet: Equatable, ExpressibleByArrayLiteral {
    public var ranges: [ClosedRange<Int>]

    public init(_ ranges: [ClosedRange<Int>] = []) {
        self.ranges = ranges
    }

    public init(arrayLiteral elements: ClosedRange<Int>...) {
        self.init(elements)
    }

    public func contains(_ line: Int) -> Bool {
        ranges.contains { $0.contains(line) }
    }
}

