
import Foundation

struct FrameDrawingState {
    let beginMs: Int
    let scaleNs: Int

    init() {
        beginMs = 0
        scaleNs = 10000
    }
}