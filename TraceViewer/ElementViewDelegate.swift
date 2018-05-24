
import Foundation

protocol ElementViewDelegate {
    func mouseDragged(deltaX: CGFloat)
    func closeButtonClicked(frameView: FrameView)
    func moveDownButtonClicked(frameView: FrameView)
    func moveUpButtonClicked(frameView: FrameView)
}