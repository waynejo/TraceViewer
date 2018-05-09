
import Foundation
import Cocoa
import AppKit

class TimeTextView: NSView {

    // drawing configurations
    let chartLeftMargin = 20

    var traceInfo: TraceInfo = TraceInfo()
    var drawingState = FrameDrawingState()
    var mouseDragDelegate: ElementViewDelegate?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        drawBackground(context: context, dirtyRect: dirtyRect)
        drawBottomLabels()
    }

    private func drawBottomLabels() {
        let beginNs = drawingState.beginNs
        let scaleNs = drawingState.scaleNs
        let width: Int = Int(frame.width)
        let left = chartLeftMargin
        let yPos = 20
        let xDelta = 100

        let textColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1.0)
        let textAttributes = [
            NSAttributedStringKey.font: NSFont.systemFont(ofSize: 15),
            NSAttributedStringKey.foregroundColor: textColor,
        ]
        for xPos in stride(from: left, to: width, by: xDelta) {
            let time = (beginNs + Int64(scaleNs * Double(xPos - left))) / 1000
            let timeText = String(time)
            let size = timeText.size(withAttributes: textAttributes)
            timeText.draw(at: NSMakePoint(CGFloat(xPos) - size.width / 2.0, CGFloat(yPos)), withAttributes: textAttributes)
        }
    }

    private func drawBackground(context: CGContext, dirtyRect: NSRect) {
        context.setFillColor(red: 0.235, green: 0.247, blue: 0.254, alpha: 1.0)
        context.fill(dirtyRect)
    }

    public func update(traceInfo: TraceInfo) {
        self.traceInfo = traceInfo
        update(drawingState: FrameDrawingState(beginNs: traceInfo.minTimeNs, scaleNs: drawingState.scaleNs))

        self.display()
    }

    public func update(drawingState: FrameDrawingState) {
        self.drawingState = drawingState

        self.display()
    }

    func setMouseDragDelegate(delegate: ElementViewDelegate) {
        mouseDragDelegate = delegate
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        mouseDragDelegate?.mouseDragged(deltaX: event.deltaX)
    }
}