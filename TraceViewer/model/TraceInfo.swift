
import Foundation

class TraceInfo {
    var traceStack: [TraceStack]
    var threads: [ThreadInfo]
    var methodMap: [Int: String]

    init(traceStack: [TraceStack] = [TraceStack](), threads: [ThreadInfo] = [ThreadInfo](), methodMap: [Int: String] = [Int: String]()) {
        self.traceStack = traceStack
        self.threads = threads
        self.methodMap = methodMap
    }

    func updateMethod(id: Int, name: String) {
        methodMap.updateValue(name, forKey: id)
    }

    func append(threadInfo: ThreadInfo) {
        threads.append(threadInfo)
    }

    func update(traceStack: [TraceStack]) {
        self.traceStack = traceStack
    }
}