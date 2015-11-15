//
//  NSUserDefaults.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 15/11/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

extension NSUserDefaults
{
    
    func setColor(value: NSColor, forKey key: String)
    {
        let data = NSArchiver.archivedDataWithRootObject(value)
        self.setObject(data, forKey: key)
    }
    
    func colorForKey(key: String) -> NSColor?
    {
        if let data = self.dataForKey(key), let object = NSUnarchiver.unarchiveObjectWithData(data)
        {
            return object as? NSColor
        }
        return nil
    }
    
}