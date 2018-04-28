
import Foundation
import Cocoa
import AppKit

class FrameView: NSView {

    var drawingState = FrameDrawingState()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        drawBackground(context: context, dirtyRect: dirtyRect)
        drawBottomLabels()
    }

    private func drawBottomLabels() {
        let width: Int = Int(frame.width)
        let left = 20
        let yPos = 20
        let xDelta = 100

        let textColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1.0)
        let textAttributes = [
            NSAttributedStringKey.font: NSFont.systemFont(ofSize: 15),
            NSAttributedStringKey.foregroundColor: textColor,
        ]
        for xPos in stride(from: left, to: width, by: xDelta) {
            let time = drawingState.beginMs + (drawingState.scaleNs * (xPos - left) / 1000)
            let timeText = String(time)
            let size = timeText.size(withAttributes: textAttributes)
            timeText.draw(at: NSMakePoint(CGFloat(xPos) - size.width / 2.0, CGFloat(yPos)), withAttributes: textAttributes)
        }
    }

    private func drawBackground(context: CGContext, dirtyRect: NSRect) {
        context.setFillColor(red: 0.235, green: 0.247, blue: 0.254, alpha: 1.0)
        context.fill(dirtyRect)
    }
}