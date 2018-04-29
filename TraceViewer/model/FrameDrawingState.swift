
import Foundation

struct FrameDrawingState {
    let beginNs: Int64
    let scaleNs: Double

    init() {
        beginNs = 0
        scaleNs = 10000
    }

    init(beginNs: Int64, scaleNs: Double) {
        self.beginNs = beginNs
        self.scaleNs = scaleNs
    }

    func update(beginNs: Int64) -> FrameDrawingState {
        return FrameDrawingState(beginNs: beginNs, scaleNs: scaleNs)
    }

    func update(scaleNs: Double) -> FrameDrawingState {
        return FrameDrawingState(beginNs: beginNs, scaleNs: max(1.0, scaleNs))
    }
}