
import Foundation

class AndroidTraceParser {

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

    private static func read(data: NSData, idx: Int) -> [TraceStack] {
        let bytes: UnsafeRawPointer = data.bytes
        let offset = Int(bytes.load(fromByteOffset: idx + 2, as: UInt8.self))
        let root = TraceStack(beginNs: 0, endNs: 0)

        var currentTrace = root
        var history: [TraceStack] = [TraceStack]()
        for i in stride(from: idx + offset + 10, to: data.length, by: 14) {
            let threadId = bytes.advanced(by: i).assumingMemoryBound(to: UInt16.self).pointee
            let methodIdWithFlag = bytes.advanced(by: i + 2).assumingMemoryBound(to: UInt32.self).pointee
            let wallTime = bytes.advanced(by: i + 10).assumingMemoryBound(to: UInt32.self).pointee
            let methodId = methodIdWithFlag >> 2
            let isStart = 0 == methodId & 1
            if isStart {
                let childTrack = TraceStack(beginNs: Int64(wallTime) * 1000, endNs: Int64(wallTime) * 1000)
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

    static func parse(path: String) -> [TraceStack] {
        guard let data = NSData(contentsOfFile: path),
              let dataIdx = index(ofStackData: data) else {
            return [TraceStack]()
        }

        return read(data: data, idx: dataIdx)
    }
}
