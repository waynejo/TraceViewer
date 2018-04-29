
import Foundation
import Cocoa
import AppKit

class FrameView: NSView {

    // drawing configurations
    let chartLeftMargin = 20
    let chartBottomMargin = 40
    let chartBarHeight = 15
    let stacks = [TraceStack]()


    var drawingState = FrameDrawingState()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        drawBackground(context: context, dirtyRect: dirtyRect)
        drawBottomLabels()
        drawingChart(context: context, stacks: stacks)
    }

    private func drawingChart(context: CGContext, stacks: [TraceStack]) {
        let beginNs = drawingState.beginNs
        let scaleNs = drawingState.scaleNs
        let left = chartLeftMargin
        let width = Int(frame.width)
        let chartWidth = width - left
        let endNs = scaleNs * Int64(width - left)

        for stack in stacks {
            if endNs <= stack.beginNs || beginNs >= stack.endNs {
                continue
            }

            let xBegin = max(0, Int((stack.beginNs - beginNs) / scaleNs))
            let xEnd = min(chartWidth, Int((stack.endNs - beginNs) / scaleNs))
            context.setFillColor(red: 0.501, green: 0.694, blue: 0.796, alpha: 1.0)
            context.fill(NSRect(x: left + xBegin, y: chartBottomMargin, width: max(1, xEnd - xBegin), height: chartBarHeight))
        }
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
            let time = (beginNs + scaleNs * Int64(xPos - left)) / 1000
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