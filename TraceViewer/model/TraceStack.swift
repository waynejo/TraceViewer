
import Foundation

class TraceStack {
    var beginNs: Int64
    var endNs: Int64
    var children: [TraceStack]

    public init(beginNs: Int64, endNs: Int64) {
        self.beginNs = beginNs
        self.endNs = endNs
        self.children = [TraceStack]()
    }

    public func update(endNs: Int64) {
        self.endNs = endNs
    }
}