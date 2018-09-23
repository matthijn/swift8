//
//  NSUserDefaults.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 15/11/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

extension UserDefaults
{
    
    func setColor(color value: NSColor, forKey key: String)
    {
        let data = NSArchiver.archivedData(withRootObject: value)
        self.set(data, forKey: key)
    }
    
    func color(for key: String) -> NSColor?
    {
        if let data = self.data(forKey: key), let object = NSUnarchiver.unarchiveObject(with: data)
        {
            return object as? NSColor
        }
        return nil
    }
    
}
