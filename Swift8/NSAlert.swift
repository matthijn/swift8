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

    static func showSimpleWarning(message warning: String, inWindow window: NSWindow)
    {
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = warning
        alert.alertStyle = .warning
        alert.beginSheetModal(for: window, completionHandler: nil)
    }

}
