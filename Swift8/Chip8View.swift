//
//  View.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 21/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

class Chip8View : NSView, Chip8Graphics
{
    let keyboard = Keyboard()
    
    // Let the main view get all the keyspresses
    override var acceptsFirstResponder : Bool {
        get {
            return true
        }
    }
    
    // MARK: Chip8Graphics
    
    /**
     * Clear the screen 
     */
    func clear()
    {
        
    }
    
    /**
     * Draw sprite data on location, removing existing color if written again at the same location, returning true if that is the case
     */
    func draw(spriteData: ArraySlice<UInt8>, x: UInt8, y: UInt8) -> Bool
    {
        return false
    }
    
    // MARK: Keyboard keys forwarding

    override func keyUp(theEvent: NSEvent) {
        self.keyboard.keyUp(theEvent)
    }

    override func keyDown(theEvent: NSEvent) {
        self.keyboard.keyDown(theEvent)
    }
}