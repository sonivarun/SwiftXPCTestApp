//
//  AppDelegate.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: HashCalculatorWindowController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainWindowController = HashCalculatorWindowController(hashCalculator: XPCHashCalculator())
        mainWindowController.showWindow(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
