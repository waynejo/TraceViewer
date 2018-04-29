
import Foundation

struct FrameDrawingState {
    let beginNs: Int64
    let scaleNs: Int64

    init() {
        beginNs = 0
        scaleNs = 10000
    }
}