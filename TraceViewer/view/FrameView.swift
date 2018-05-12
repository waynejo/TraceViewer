
import Foundation
import Cocoa
import AppKit

class FrameView: NSView {

    // drawing configurations
    let chartLeftMargin = 20
    let chartBottomMargin = 10
    let chartBarHeight = 15
    let chartMinTextWidth = 20
    let barColors = [
        Color(red: 0.501, green: 0.694, blue: 0.796),
        Color(red: 0.580, green: 0.812, blue: 0.631)
    ]
    let bottomLineColor = Color(red: 0.6, green: 0.6, blue: 0.6)

    static let closeBtnImage: NSImage = NSImage(named: NSImage.Name("close"))!

    var traceInfo: TraceInfo = TraceInfo()
    var threadInfo: ThreadInfo = ThreadInfo()
    var drawingState = FrameDrawingState()
    var elementViewDelegate: ElementViewDelegate?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }

        drawBackground(context: context, dirtyRect: dirtyRect)
        drawingChart(context: context, stacks: threadInfo.traceStacks)
        drawBottomLine(context: context)
        drawCloseBtn(context: context)
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

    private func drawBackground(context: CGContext, dirtyRect: NSRect) {
        context.setFillColor(red: 0.235, green: 0.247, blue: 0.254, alpha: 1.0)
        context.fill(dirtyRect)
    }

    private func drawBottomLine(context: CGContext) {
        context.setFillColor(red: bottomLineColor.red, green: bottomLineColor.green, blue: bottomLineColor.blue, alpha: 1.0)
        let drawingRect: CGRect = NSRect(x: 0, y: 0, width: Int(frame.width), height: 1)
        context.fill(drawingRect)
    }

    private func drawCloseBtn(context: CGContext) {
        FrameView.closeBtnImage.draw(in: closeBtnRect())
    }

    public func update(traceInfo: TraceInfo, threadInfo: ThreadInfo) {
        self.traceInfo = traceInfo
        self.threadInfo = threadInfo;
        update(drawingState: FrameDrawingState(beginNs: traceInfo.minTimeNs, scaleNs: drawingState.scaleNs))

        self.display()
    }

    private func closeBtnRect() -> NSRect {
        let leftMargin = 3
        let topMargin = 3
        let width = 15
        let height = 15
        return NSRect(x: leftMargin, y: Int(frame.height) - height - topMargin, width: width, height: height)
    }

    public func update(drawingState: FrameDrawingState) {
        self.drawingState = drawingState

        self.display()
    }

    func setMouseDragDelegate(delegate: ElementViewDelegate) {
        elementViewDelegate = delegate
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        elementViewDelegate?.mouseDragged(deltaX: event.deltaX)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        let btnRect = closeBtnRect()
        let point = convert(event.locationInWindow, from:nil)

        if NSPointInRect(point, btnRect) {
            elementViewDelegate?.closeButtonClicked(frameView: self)
        }
    }
}