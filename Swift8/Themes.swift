//
//  Themes.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 15/11/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

class Theme
{
    
    let name : String
    let backgroundColor: NSColor
    let foregroundColor : NSColor
    
    init(name: String, backgroundColor: NSColor, foregroundColor: NSColor)
    {
        self.name = name
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

}

class Themes
{
 
    static let defaultTheme = Theme(name: "Tangerine", backgroundColor: NSColor(calibratedRed: 0.69, green: 0.37, blue: 0, alpha: 1), foregroundColor: NSColor(calibratedRed: 1, green: 0.77, blue: 0, alpha: 1))
    
    static let availableThemes = [
        Theme(name: "Classic", backgroundColor: NSColor(calibratedWhite: 0.1, alpha: 1), foregroundColor: NSColor(calibratedWhite: 0.95, alpha: 1)),
        
        Theme(name: "Lavender", backgroundColor: NSColor(calibratedRed:0.31, green:0.27, blue:0.85, alpha:1), foregroundColor: NSColor(calibratedRed:0.64, green:0.59, blue:1, alpha:1)),
        
        Theme(name: "Parsley", backgroundColor: NSColor(calibratedRed:0.04, green:0.29, blue:0.11, alpha:1), foregroundColor: NSColor(calibratedRed:0.39, green:0.57, blue:0.15, alpha:1)),
        
        defaultTheme
    ]
    
}