
import Foundation

class TraceInfo {

    var threads: [ThreadInfo]
    var methodMap: [Int: String]
    let minTimeNs: Int64
    let maxTimeNs: Int64

    init(threads: [ThreadInfo] = [ThreadInfo](),
         methodMap: [Int: String] = [Int: String](),
         minTimeNs: Int64 = 0,
         maxTimeNs: Int64 = 0) {

        self.threads = threads
        self.methodMap = methodMap
        self.minTimeNs = minTimeNs
        self.maxTimeNs = maxTimeNs
    }

    func updateMethod(id: Int, name: String) {
        methodMap.updateValue(name, forKey: id)
    }

    func append(threadInfo: ThreadInfo) {
        threads.append(threadInfo)
    }

    func minMaxUpdated() -> TraceInfo {
        let newMinTime: Int64 = threads.flatMap {
            $0.traceStacks.map {
                $0.minTimeNs()
            }
        }.min() ?? 0
        let newMaxTime: Int64 = threads.flatMap {
            $0.traceStacks.map {
                $0.maxTimeNs()
            }
        }.max() ?? 0

        return TraceInfo(
            threads: threads,
            methodMap: methodMap,
            minTimeNs: newMinTime,
            maxTimeNs: newMaxTime
        )
    }
}