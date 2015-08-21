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
        19: 0x1, // 1
        20: 0x2, // 2
        21: 0x3, // 3
        22: 0x4, // 4
        23: 0x5, // 5
        24: 0x6, // 6
        25: 0x7, // 7
        26: 0x8, // 8
        27: 0x9, // 9
        28: 0x0, // 0
        0:  0xA, // a
        11: 0xB, // b
        8:  0xC, // c
        2:  0xD, // d
        14: 0xE, // e
        3:  0xF, // f
    ]
    
    var currentKey : Int8 = -1

    func keyUp(event: NSEvent)
    {
        // Key stopped being pressed so setting current key to 0
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