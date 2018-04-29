
import Foundation

struct TraceStack {
    let beginNs: Int64
    let endNs: Int64
    let children: [TraceStack]

    public init(beginNs: Int64, endNs: Int64) {
        self.beginNs = beginNs
        self.endNs = endNs
        self.children = [TraceStack]()
    }
}