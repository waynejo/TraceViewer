//
//  ViewController.swift
//  TraceViewer
//
//  Created by waynejo on 2018. 4. 28..
//  Copyright © 2018년 waynejo. All rights reserved.
//

import Cocoa
import SnapKit

class ViewController: NSViewController, NSWindowDelegate, NSSearchFieldDelegate {
    static let topMarginForStackView = 52

    @IBOutlet weak var threadPopupButton: NSPopUpButton!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var addingThreadButton: NSButton!
    
    let textViewHeight = 40

    var traceInfo = TraceInfo()
    var drawingState = FrameDrawingState()
    var frameViewList = [FrameView]()
    let timeTextView: TimeTextView = TimeTextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false

        timeTextView.setMouseDragDelegate(delegate: self)
        view.addSubview(timeTextView)

        didTraceInfoUpdated()

        searchField.delegate = self

        updateLayout()
        updateComboBox()
        setupAddingThreadButton()
    }

    private func didTraceInfoUpdated() {
        for frameView in frameViewList {
            frameView.removeFromSuperview()
        }
        frameViewList.removeAll()

        for thread in traceInfo.threads {
            addThreadView(thread: thread)
        }

        timeTextView.update(traceInfo: traceInfo)
        update(drawingState: FrameDrawingState(beginNs: traceInfo.minTimeNs, scaleNs: drawingState.scaleNs))
        updateLayout()
    }

    private func addThreadView(thread: ThreadInfo) {
        let frameView = FrameView()
        frameView.update(traceInfo: traceInfo, threadInfo: thread)
        frameView.setMouseDragDelegate(delegate: self)
        frameViewList.append(frameView)
        view.addSubview(frameView)
    }

    private func bringToFront(view childView: NSView) {
        childView.removeFromSuperview()
        view.addSubview(childView)
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

    func setupAddingThreadButton() {
        addingThreadButton.target = self
        addingThreadButton.action = #selector(ViewController.didAddingThreadButtonClicked)
    }

    @objc func didAddingThreadButtonClicked() {
        addThreadView(thread: traceInfo.threads[threadPopupButton.indexOfSelectedItem])
        updateLayout()
    }

    func updateLayout() {
        let rect = view.frame
        timeTextView.frame = NSRect(x: 0, y: 0, width: Int(rect.width), height: textViewHeight)
        timeTextView.display()

        let viewNum = frameViewList.count
        let viewTopMargin = textViewHeight
        let viewBottomMargin = ViewController.topMarginForStackView
        let viewHeight = Int(rect.height) - viewBottomMargin - viewTopMargin
        for idx in 0..<viewNum {
            let yBegin = viewHeight * idx / viewNum + viewTopMargin
            let yEnd = viewHeight * (idx + 1) / viewNum + viewTopMargin
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

    func removeFrameView(frameView: FrameView) {
        frameView.removeFromSuperview()
        frameViewList = frameViewList.filter() { $0 !== frameView }
        updateLayout()
    }

    override func controlTextDidChange(_ obj: Notification) {
        let text = searchField.stringValue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.searchField.stringValue == text {
                let nextState = self.drawingState.update(searchText: text)
                self.update(drawingState: nextState)
            }
        }
    }

    func moveView(frameView: FrameView, delta: Int) {
        let begin = max(0, delta)
        let end = frameViewList.count - max(0, delta)
        for idx in begin..<end {
            if frameViewList[idx] == frameView {
                let view = frameViewList[idx]
                frameViewList[idx] = frameViewList[idx + delta]
                frameViewList[idx + delta] = view
                updateLayout()
                break
            }
        }
    }

    func loadFile(filePath: String) {
        traceInfo = AndroidTraceParser.parse(path: filePath)
        didTraceInfoUpdated()
    }
}

extension ViewController: ElementViewDelegate {
    func mouseDragged(deltaX: CGFloat) {
        let nsDelta = Int64(drawingState.scaleNs * Double(deltaX))
        let nextState = drawingState.update(beginNs: drawingState.beginNs - nsDelta)
        update(drawingState: nextState)
    }

    func closeButtonClicked(frameView: FrameView) {
        removeFrameView(frameView: frameView)
    }

    func moveDownButtonClicked(frameView: FrameView) {
        moveView(frameView: frameView, delta: -1)
    }

    func moveUpButtonClicked(frameView: FrameView) {
        moveView(frameView: frameView, delta: 1)
    }
}
