
import Foundation

class ThreadInfo {
    let id: Int
    let name: String
    var traceStacks: [TraceStack]


    init(id: Int, name: String, traceStacks: [TraceStack] = [TraceStack]()) {
        self.id = id
        self.name = name
        self.traceStacks = traceStacks
    }

    func update(traceStacks: [TraceStack]) {
        self.traceStacks = traceStacks
    }
}