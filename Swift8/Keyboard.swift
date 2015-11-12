//
//  Keyboard.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 18/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

class Keyboard
{
    
    // Mapping ASCII keycodes to the Chip8 key codes
    let mapping : [UInt8: Int8] = [
        18: 0x1, // 1
        19: 0x2, // 2
        20: 0x3, // 3
        21: 0x4, // 4
        12: 0x5, // q
        13: 0x6, // w
        14: 0x7, // e
        15: 0x8, // r
        0: 0x9, // a
        1: 0x0, // s
        2:  0xA, // d
        3: 0xB, // f
        6:  0xC, // z
        7:  0xD, // x
        8: 0xE, // c
        9:  0xF, // v
    ]
    
    var currentKey : Int8 = -1

    func keyUp(event: NSEvent)
    {
        // Key stopped being pressed so setting current key to -1 to represent nothing
        self.currentKey = -1
    }
    
    func keyDown(event: NSEvent)
    {
        // Setting the current key as the mapped key
        if let mappedKey = self.mapping[UInt8(event.keyCode)]
        {
            self.currentKey = mappedKey
        }
    }
    
}