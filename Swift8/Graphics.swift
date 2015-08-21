//
//  Graphics.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 18/08/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Foundation

protocol Chip8Graphics
{
    
    // Clear the screen
    func clear()
    
    
    // Draw sprite data on given location, return true if it overwrites existing information
    func draw(spriteData: ArraySlice<UInt8>, x: UInt8, y: UInt8) -> Bool
    
}

class Graphics : Chip8Graphics
{
    
    // Holds the font data that will be loaded in memory to display numbers on screen
    static let FontSpriteData : [UInt8] = [
        0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
        0x90, 0x90, 0xF0, 0x10, 0x10, // 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
        0xF0, 0x10, 0x20, 0x40, 0x40, // 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, // A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
        0xF0, 0x80, 0x80, 0x80, 0xF0, // C
        0xE0, 0x90, 0x90, 0x90, 0xE0, // D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
        0xF0, 0x80, 0xF0, 0x80, 0x80 // F
    ]
    
    // Forwarding the drawing calls to another class, so it can be swapped for different type (e.g UIView, OpenGL, ASCII)
    let delegate : Chip8Graphics

    init(graphicsDelegate: Chip8Graphics)
    {
        self.delegate = graphicsDelegate
    }
    
    /**
     * Clear everything that is displayed
     */
    func clear()
    {
        self.delegate.clear()
    }
    
    /**
     * Draw the sprite data on the given location
     * @return Bool if the sprite overlaps with existing sprite and overwrites it partially (inverting) true is returned, else false
     */
    func draw(spriteData: ArraySlice<UInt8>, x: UInt8, y: UInt8) -> Bool
    {
        return self.delegate.draw(spriteData, x: x, y: y)
    }

}