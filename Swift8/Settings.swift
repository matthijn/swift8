//
//  Settings.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 14/11/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Cocoa

enum Setting : String
{
    case BackgroundColor = "backgroundColor"
    case ForegroundColor = "foregroundColor"
    case RenderSpeed = "renderSpeed"
    case PlaySound = "playSound"
    case DidSetDefaultValues = "didSetDefaultValues"
}

class Settings
{
    // Defaulting to standardUserDefaults and defaultCenter to save and broadcast the settings information
    static let sharedSettings = Settings(defaults: NSUserDefaults.standardUserDefaults())

    // Using NSUserdefaults to store the information
    let defaults : NSUserDefaults

    init(defaults: NSUserDefaults)
    {
        self.defaults = defaults
        
        self.checkDefaultValues()
    }
    
    // MARK: The settings

    var theme : Theme {
        get {
            let backgroundColor = self.defaults.colorForKey(Setting.BackgroundColor.rawValue)
            let foregroundColor = self.defaults.colorForKey(Setting.ForegroundColor.rawValue)
        
            return Theme(name: "Settings", backgroundColor: backgroundColor!, foregroundColor: foregroundColor!)
        }
        set {
            self.defaults.setColor(newValue.backgroundColor, forKey: Setting.BackgroundColor.rawValue)
            self.defaults.setColor(newValue.foregroundColor, forKey: Setting.ForegroundColor.rawValue)
            self.defaults.synchronize()
        }
    }

    var renderSpeed : Double {
        get {
            return self.defaults.doubleForKey(Setting.RenderSpeed.rawValue)
        }
        set
        {
            self.defaults.setDouble(newValue, forKey: Setting.RenderSpeed.rawValue)
            self.defaults.synchronize()
        }
    }
    
    var playSound : Bool {
        get {
            return self.defaults.boolForKey(Setting.PlaySound.rawValue)
        }
        set {
            self.defaults.setBool(newValue, forKey: Setting.PlaySound.rawValue)
            self.defaults.synchronize()
        }
    }
    
    // MARK Handling default values
    
    // Checks if we set initial default values, if not we will
    private func checkDefaultValues()
    {
        if !self.defaults.boolForKey(Setting.DidSetDefaultValues.rawValue)
        {
            self.setDefaultValues()
            self.defaults.setBool(true, forKey: Setting.DidSetDefaultValues.rawValue)
        }
    }
    
    // Sets the initial default values
    private func setDefaultValues()
    {
        self.theme = Themes.defaultTheme
        self.renderSpeed = 0.5
        self.playSound = true
    }

}