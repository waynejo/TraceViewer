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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let frameView = FrameView()
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
}

