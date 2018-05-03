
import Foundation

class TraceInfo {

    var threads: [ThreadInfo]
    var methodMap: [Int: String]

    init(threads: [ThreadInfo] = [ThreadInfo](),
         methodMap: [Int: String] = [Int: String]()) {

        self.threads = threads
        self.methodMap = methodMap
    }

    func updateMethod(id: Int, name: String) {
        methodMap.updateValue(name, forKey: id)
    }

    func append(threadInfo: ThreadInfo) {
        threads.append(threadInfo)
    }
}