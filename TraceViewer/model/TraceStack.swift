
import Foundation

class TraceStack {
    var methodId: Int
    var beginNs: Int64
    var endNs: Int64
    var children: [TraceStack]

    public init(methodId: Int = -1, beginNs: Int64 = 0, endNs: Int64 = 0) {
        self.methodId = methodId
        self.beginNs = beginNs
        self.endNs = endNs
        self.children = [TraceStack]()
    }

    public func update(endNs: Int64) {
        self.endNs = endNs
    }

    public func minTimeNs() -> Int64 {
        let childrenMin = children.map {
            $0.minTimeNs()
        }.min()

        return min(beginNs, min(endNs, childrenMin ?? beginNs))
    }

    public func maxTimeNs() -> Int64 {
        let childrenMin = children.map {
            $0.maxTimeNs()
        }.max()

        return max(beginNs, max(endNs, childrenMin ?? endNs))
    }
}