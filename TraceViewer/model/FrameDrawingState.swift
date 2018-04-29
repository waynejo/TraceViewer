
import Foundation

struct FrameDrawingState {
    let beginNs: Int64
    let scaleNs: Int64

    init() {
        beginNs = 0
        scaleNs = 10000
    }

    init(beginNs: Int64, scaleNs: Int64) {
        self.beginNs = beginNs
        self.scaleNs = scaleNs
    }

    func update(beginNs: Int64) -> FrameDrawingState {
        return FrameDrawingState(beginNs: beginNs, scaleNs: scaleNs)
    }

    func update(scaleNs: Int64) -> FrameDrawingState {
        return FrameDrawingState(beginNs: beginNs, scaleNs: scaleNs)
    }
}