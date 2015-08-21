//
//  View.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 21/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

class Chip8View : NSView
{
    let keyboard = Keyboard()
    
    // Let the main view get all the keyspresses
    override var acceptsFirstResponder : Bool {
        get {
            return true
        }
    }
    
    // MARK: Keyboard keys forwarding

    override func keyUp(theEvent: NSEvent) {
        self.keyboard.keyUp(theEvent)
    }

    override func keyDown(theEvent: NSEvent) {
        self.keyboard.keyDown(theEvent)
    }
}