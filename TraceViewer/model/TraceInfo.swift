
import Foundation

class TraceInfo {
    var traceStack: [TraceStack]
    var methodMap: [Int: String]

    init(traceStack: [TraceStack] = [TraceStack](), methodMap: [Int: String] = [Int: String]()) {
        self.traceStack = traceStack
        self.methodMap = methodMap
    }

    func updateMethod(id: Int, name: String) {
        methodMap.updateValue(name, forKey: id)
    }

    func update(traceStack: [TraceStack]) {
        self.traceStack = traceStack
    }
}