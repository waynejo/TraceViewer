
import Foundation

class ThreadInfo {
    let id: Int
    let name: String
    let threadStacks: [TraceStack]

    init(id: Int, name: String, threadStacks: [TraceStack] = [TraceStack]()) {
        self.id = id
        self.name = name
        self.threadStacks = threadStacks
    }
}