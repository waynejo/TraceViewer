
import Foundation

struct FrameDrawingState {
    let beginNs: Int64
    let scaleNs: Double
    let searchText: String

    init() {
        beginNs = 0
        scaleNs = 10000
        searchText = ""
    }

    init(beginNs: Int64, scaleNs: Double, searchText: String = "") {
        self.beginNs = beginNs
        self.scaleNs = scaleNs
        self.searchText = searchText
    }

    func update(beginNs: Int64) -> FrameDrawingState {
        return FrameDrawingState(beginNs: beginNs, scaleNs: scaleNs, searchText: searchText)
    }

    func update(scaleNs: Double) -> FrameDrawingState {
        return FrameDrawingState(beginNs: beginNs, scaleNs: max(1.0, scaleNs), searchText: searchText)
    }

    func update(searchText: String) -> FrameDrawingState {
        return FrameDrawingState(beginNs: beginNs, scaleNs: scaleNs, searchText: searchText)
    }
}