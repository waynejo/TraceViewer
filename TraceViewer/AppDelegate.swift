//
//  AppDelegate.swift
//  TraceViewer
//
//  Created by waynejo on 2018. 4. 28..
//  Copyright © 2018년 waynejo. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    @IBAction func openDocument(_ sender: Any) {
        guard let viewController = NSApplication.shared.mainWindow?.windowController?.contentViewController as? ViewController else {
            return
        }
        let dialog = NSOpenPanel()
        dialog.title = "Choose a .trace file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["trace"]

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url
            if result != nil,
                let path = result?.path {
                viewController.loadFile(filePath: path)
            }
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

