//
//  NSAlert.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 17/11/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

extension NSAlert
{

    static func showSimpleWarning(warning: String, inWindow window: NSWindow)
    {
        let alert = NSAlert()
        alert.addButtonWithTitle("OK")
        alert.messageText = warning
        alert.alertStyle = .WarningAlertStyle
        alert.beginSheetModalForWindow(window, completionHandler: nil)
    }

}