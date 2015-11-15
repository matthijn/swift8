//
//  Settings.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 14/11/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

class Settings
{
    // Defaulting to standardUserDefaults and defaultCenter to save and broadcast the settings information
    static let sharedSettings = Settings(defaults: NSUserDefaults.standardUserDefaults())

    // Using NSUserdefaults to store the information
    let defaults : NSUserDefaults

    init(defaults: NSUserDefaults)
    {
        self.defaults = defaults
    }
    
    // MARK: The settings

    var theme : Theme {
        get {
            if let backgroundColor = self.defaults.colorForKey("backgroundColor"), let foregroundColor = self.defaults.colorForKey("foregroundColor")
            {
                return Theme(name: "Settings", backgroundColor: backgroundColor, foregroundColor: foregroundColor)
            }
            return Themes.defaultTheme
        }
        set {
            self.defaults.setColor(theme.backgroundColor, forKey: "backgroundColor")
            self.defaults.setColor(theme.foregroundColor, forKey: "foregroundColor")
            self.defaults.synchronize()
        }
    }

    var renderSpeed : Double {
        get {
            let settingSpeed = self.defaults.doubleForKey("renderSpeed")
            
            if settingSpeed > 0
            {
                return settingSpeed
            }
            
            return 500.0
        }
        set
        {
            self.defaults.setDouble(newValue, forKey: "renderSpeed")
            self.defaults.synchronize()
        }
    }

}