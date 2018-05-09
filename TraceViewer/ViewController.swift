//
//  ViewController.swift
//  TraceViewer
//
//  Created by waynejo on 2018. 4. 28..
//  Copyright © 2018년 waynejo. All rights reserved.
//

import Cocoa
import SnapKit

class ViewController: NSViewController, NSWindowDelegate {
    @IBOutlet weak var threadPopupButton: NSPopUpButton!

    let textViewHeight = 40

    var traceInfo = TraceInfo()
    var drawingState = FrameDrawingState()
    var frameViewList = [FrameView]()
    let timeTextView: TimeTextView = TimeTextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false


        for thread in traceInfo.threads {
            let frameView = FrameView()
            frameView.update(traceInfo: traceInfo, threadInfo: thread)
            frameView.setMouseDragDelegate(delegate: self)
            frameViewList.append(frameView)
            view.addSubview(frameView)
        }

        timeTextView.update(traceInfo: traceInfo)
        timeTextView.setMouseDragDelegate(delegate: self)
        view.addSubview(timeTextView)

        update(drawingState: FrameDrawingState(beginNs: traceInfo.minTimeNs, scaleNs: drawingState.scaleNs))
        updateLayout()
        updateComboBox()

        threadPopupButton.removeFromSuperview()
        view.addSubview(threadPopupButton)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        self.view.window?.delegate = self
        updateLayout()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func updateComboBox() {
        threadPopupButton.removeAllItems()
        for thread in traceInfo.threads {
            threadPopupButton.addItem(withTitle: thread.name)
        }
    }

    func updateLayout() {
        guard let rect = view.window?.frame else {
            return
        }
        timeTextView.frame = NSRect(x: 0, y: 0, width: Int(rect.width), height: textViewHeight)
        timeTextView.display()

        let viewNum = frameViewList.count
        let viewHeight = Int(rect.height)
        for idx in 0..<viewNum {
            let yBegin = viewHeight * idx / viewNum
            let yEnd = viewHeight * (idx + 1) / viewNum
            frameViewList[idx].frame = NSRect(x: 0, y: yBegin, width: Int(rect.width), height: yEnd - yBegin)
            frameViewList[idx].display()
        }
    }

    public func update(drawingState: FrameDrawingState) {
        self.drawingState = drawingState

        for frameView in frameViewList {
            frameView.update(drawingState: drawingState)
            frameView.display()
        }
        timeTextView.update(drawingState: drawingState)
        timeTextView.display()
    }

    func windowDidResize(_ notification: Notification) {
        updateLayout()
    }

    public func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self)
    }

    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)

        if event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command) {
            let scaleBase = 2.0
            let scaled = pow(Double(drawingState.scaleNs), 1.0 / scaleBase)
            let nextState = drawingState.update(scaleNs: pow(scaled - Double(event.deltaY), scaleBase))
            update(drawingState: nextState)
        } else {
            let nextState = drawingState.update(beginNs: drawingState.beginNs - Int64(drawingState.scaleNs * Double(event.deltaY)))
            update(drawingState: nextState)
        }
    }
}

extension ViewController: ElementViewDelegate {
    func mouseDragged(deltaX: CGFloat) {
        let nsDelta = Int64(drawingState.scaleNs * Double(deltaX))
        let nextState = drawingState.update(beginNs: drawingState.beginNs - nsDelta)
        update(drawingState: nextState)
    }
}