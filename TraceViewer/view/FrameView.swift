
import Foundation
import Cocoa
import AppKit

class FrameView: NSView {

    // drawing configurations
    let chartLeftMargin = 20
    let chartBottomMargin = 40
    let chartBarHeight = 15
    let chartMinTextWidth = 20
    let barColors = [
        Color(red: 0.501, green: 0.694, blue: 0.796),
        Color(red: 0.580, green: 0.812, blue: 0.631)
    ]

    var traceInfo: TraceInfo = TraceInfo()
    var drawingState = FrameDrawingState()

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        traceInfo.traceStack.append(TraceStack(beginNs: 1000, endNs: 2500))
        traceInfo.traceStack.append(TraceStack(beginNs: 1000000, endNs: 2000000))

        drawBackground(context: context, dirtyRect: dirtyRect)
        drawBottomLabels()
        drawingChart(context: context, stacks: traceInfo.traceStack)
    }

    private func barColor(idx: Int) -> Color {
        return barColors[idx % barColors.count]
    }

    private func drawingChart(context: CGContext, stacks: [TraceStack], depth: Int = 0) {
        let beginNs = drawingState.beginNs
        let scaleNs = drawingState.scaleNs
        let left = chartLeftMargin
        let width = Int(frame.width)
        let chartWidth = width - left
        let endNs = beginNs + Int64(scaleNs * Double(width - left))

        let textColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1.0)
        let textAttributes = [
            NSAttributedStringKey.font: NSFont.systemFont(ofSize: 11),
            NSAttributedStringKey.foregroundColor: textColor,
        ]

        for idx in stacks.indices {
            let stack = stacks[idx]
            if endNs <= stack.beginNs || beginNs >= stack.endNs {
                continue
            }

            let color = barColor(idx: idx)
            let xBegin = max(0, Int(Double(stack.beginNs - beginNs) / scaleNs))
            let xEnd = min(chartWidth, Int(Double(stack.endNs - beginNs) / scaleNs))
            context.setFillColor(red: color.red, green: color.green, blue: color.blue, alpha: 1.0)

            let drawX = left + xBegin
            let drawY = chartBottomMargin + chartBarHeight * depth
            let drawWidth = max(1, xEnd - xBegin)
            let drawingRect: CGRect = NSRect(x: drawX, y: drawY, width: drawWidth, height: chartBarHeight)
            context.fill(drawingRect)

            if chartMinTextWidth < drawWidth,
                let functionName = traceInfo.methodMap[stack.methodId] {
                functionName.draw(in: drawingRect, withAttributes: textAttributes)
            }
            drawingChart(context: context, stacks: stack.children, depth: depth + 1)
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

        self.display()
    }

    public func update(drawingState: FrameDrawingState) {
        self.drawingState = drawingState

        self.display()
    }

    public func state() -> FrameDrawingState {
        return drawingState
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        let nsDelta = Int64(drawingState.scaleNs * Double(event.deltaX))
        let nextState = drawingState.update(beginNs: drawingState.beginNs - nsDelta)
        update(drawingState: nextState)
    }
}