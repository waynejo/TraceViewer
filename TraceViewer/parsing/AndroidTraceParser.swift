
import Foundation

class AndroidTraceParser {

    private static func readTraceInfo(data: NSData) -> TraceInfo? {
        let bytes: UnsafeRawPointer = data.bytes
        let dataLength = data.length
        var idx = 0
        var idxBegin = 0
        var sectionType = ParsingSection.unknown
        let traceInfo = TraceInfo()
        while (idx < dataLength) {
            let newChar = bytes.load(fromByteOffset: idx, as: UInt8.self)
            if 10 == newChar {
                let line = String(data: data.subdata(with: NSRange(location: idxBegin, length: idx - idxBegin)), encoding:.utf8) ?? ""
                if line.starts(with: "*") {
                    if line == "*version" {
                        sectionType = .version
                    } else if line == "*threads" {
                        sectionType = .threads
                    } else if line == "*methods" {
                        sectionType = .methods
                    } else {
                        sectionType = .unknown
                    }
                } else {
                    switch sectionType {
                        case .threads:
                            let words = line.split(separator: "\t")
                            let threadId = Int(words[0]) ?? -1
                            let threadName = String(words[1])
                            let threadInfo = ThreadInfo(id: threadId, name: threadName)
                            traceInfo.append(threadInfo: threadInfo)
                        case .methods:
                            let words = line.split(separator: "\t")
                            let methodId = Int(words[0].dropFirst(2), radix: 16) ?? 0
                            let className = String(words[1])
                            let methodName = String(words[2])
                            traceInfo.updateMethod(id: methodId, name: className + " " + methodName)
                        default:
                            break
                    }
                }
                idxBegin = idx + 1
            }
            idx = idx + 1
        }

        return traceInfo
    }

    private static func index(ofStackData data: NSData) -> Int? {
        let bytes: UnsafeRawPointer = data.bytes
        for i in 0 ..< data.length - 3 {
            if 0x53 == bytes.load(fromByteOffset: i, as: UInt8.self) && // S
                       0x4C == bytes.load(fromByteOffset: i + 1, as: UInt8.self) && // L
                       0x4F == bytes.load(fromByteOffset: i + 2, as: UInt8.self) && // O
                       0x57 == bytes.load(fromByteOffset: i + 3, as: UInt8.self) { // W
                return i + 4
            }
        }
        return nil
    }

    private static func read(data: NSData, idx: Int, threadId: Int) -> [TraceStack] {
        let bytes: UnsafeRawPointer = data.bytes
        let offset = Int(bytes.load(fromByteOffset: idx + 2, as: UInt8.self))
        let root = TraceStack(beginNs: 0, endNs: 0)

        var currentTrace = root
        var history: [TraceStack] = [TraceStack]()
        for i in stride(from: idx + offset + 10, to: data.length, by: 14) {
            let thread = bytes.advanced(by: i).assumingMemoryBound(to: UInt16.self).pointee
            if thread != threadId {
                continue
            }
            let methodIdWithFlag = bytes.advanced(by: i + 2).assumingMemoryBound(to: UInt32.self).pointee
            let wallTime = bytes.advanced(by: i + 10).assumingMemoryBound(to: UInt32.self).pointee
            let methodId = Int(methodIdWithFlag & (~3))
            let isStart = 0 == methodIdWithFlag & 1
            if isStart {
                let childTrack = TraceStack(methodId: methodId, beginNs: Int64(wallTime) * 1000, endNs: Int64(wallTime) * 1000)
                currentTrace.children.append(childTrack)
                currentTrace = childTrack
                history.append(childTrack)
            } else {
                if let lastElement = history.popLast() {
                    lastElement.update(endNs: Int64(wallTime) * 1000)
                }

                if let parentStack = history.last {
                    currentTrace = parentStack
                } else {
                    currentTrace = root
                }
            }
        }
        return root.children
    }

    static func parse(path: String) -> TraceInfo {
        guard let data = NSData(contentsOfFile: path),
              let traceInfo = readTraceInfo(data: data),
              let dataIdx = index(ofStackData: data) else {
            return TraceInfo()
        }

        for thread in traceInfo.threads {
            thread.update(traceStacks: read(data: data, idx: dataIdx, threadId: thread.id))
        }

        return traceInfo.minMaxUpdated()
    }
}
