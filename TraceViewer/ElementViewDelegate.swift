
import Foundation

protocol ElementViewDelegate {
    func mouseDragged(deltaX: CGFloat)
    func closeButtonClicked(frameView: FrameView)
}