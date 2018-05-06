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

    let frameView = FrameView()
    let threadComboBox: NSComboBox = NSComboBox()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(frameView)

        frameView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }

        view.addSubview(threadComboBox)
        threadComboBox.snp.makeConstraints { (make) -> Void in
            make.edges.bottom.equalTo(view.snp.bottom)
            make.edges.right.equalTo(view.snp.right)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        self.view.window?.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
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

