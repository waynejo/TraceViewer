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

    var traceInfo = TraceInfo()
    let frameView = FrameView()
    let frameView2 = FrameView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false

        frameView.update(traceInfo: traceInfo)

        view.addSubview(frameView)

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
        frameView.frame = NSRect(x: 0, y: 0, width: rect.width, height: rect.height)
        frameView.display()
    }

    func windowDidResize(_ notification: Notification) {
        updateLayout()
    }

    public func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self)
    }

    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)

        let state = frameView.state()

        if event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command) {
            let scaleBase = 2.0
            let scaled = pow(Double(state.scaleNs), 1.0 / scaleBase)
            let nextState = state.update(scaleNs: pow(scaled - Double(event.deltaY), scaleBase))
            frameView.update(drawingState: nextState)
        } else {
            let nextState = state.update(beginNs: state.beginNs - Int64(state.scaleNs * Double(event.deltaY)))
            frameView.update(drawingState: nextState)
        }
    }
}

