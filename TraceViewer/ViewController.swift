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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(frameView)

        frameView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
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
            let nextState = state.update(scaleNs: Int64(pow(scaled - Double(event.deltaY), scaleBase)))
            frameView.update(drawingState: nextState)
        } else {
            let nextState = state.update(beginNs: state.beginNs - state.scaleNs * Int64(event.deltaY))
            frameView.update(drawingState: nextState)
        }
    }
}

